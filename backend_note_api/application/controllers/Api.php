<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Api extends CI_Controller {

    public function __construct() {
        parent::__construct();
        $this->load->model('note_model');
        header('Content-Type: application/json');
        header('Access-Control-Allow-Origin: *');
        header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
        header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

        if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
            exit;
        }
    }

    public function index() {
        $method = $_SERVER['REQUEST_METHOD'];

        if ($method === 'GET') {
            $notes = $this->note_model->get_notes();
            if ($notes) {
                $response = array('status' => true, 'data' => $notes);
                echo json_encode($response);
            } else {
                $response = array('status' => true, 'data' => [], 'message' => 'No notes found.');
                echo json_encode($response);
            }
        } elseif ($method === 'POST') {
            $input_data = json_decode(file_get_contents('php://input'), true);

            if (empty($input_data['title']) || empty($input_data['content'])) {
                http_response_code(400);
                echo json_encode(array('status' => false, 'message' => 'Title and content are required.'));
                return;
            }

            $data = array(
                'title' => $input_data['title'],
                'content' => $input_data['content']
            );

            $insert_id = $this->note_model->insert_note($data);
            if ($insert_id) {
                $new_note = $this->note_model->get_note_by_id($insert_id);
                http_response_code(201);
                echo json_encode(array('status' => true, 'message' => 'Note created successfully.', 'data' => $new_note));
            } else {
                http_response_code(500);
                echo json_encode(array('status' => false, 'message' => 'Failed to create note.'));
            }
        } else {
            http_response_code(405);
            echo json_encode(array('status' => false, 'message' => 'Method not allowed for this endpoint.'));
        }
    }

    public function note($id = null) {
        if ($id === null) {
            http_response_code(400);
            echo json_encode(array('status' => false, 'message' => 'Note ID is required.'));
            return;
        }

        $method = $_SERVER['REQUEST_METHOD'];
        $note_exists = $this->note_model->get_note_by_id($id); // Cek note sekali di awal

        // Pengecekan awal jika note tidak ada, berlaku untuk GET, PUT, dan DELETE
        if (!$note_exists) {
            // Jika method adalah GET, PUT, atau DELETE dan note tidak ada, kembalikan 404
            if ($method === 'GET' || $method === 'PUT' || $method === 'DELETE') {
                http_response_code(404);
                echo json_encode(array('status' => false, 'message' => 'Note with ID ' . $id . ' not found.'));
                return;
            }
            // Untuk method lain (jika ada) yang tidak memerlukan $note_exists, bisa lanjut atau ditangani berbeda
        }

        // Sekarang $note_exists pasti berisi data note jika methodnya GET, PUT, atau DELETE
        // dan eksekusi sudah sampai sini.

        if ($method === 'GET') {
            echo json_encode(array('status' => true, 'data' => $note_exists));
        } elseif ($method === 'PUT') {
            $input_data = json_decode(file_get_contents('php://input'), true);

            if ($input_data === null && json_last_error() !== JSON_ERROR_NONE) {
                 http_response_code(400);
                 echo json_encode(array('status' => false, 'message' => 'Invalid JSON provided.'));
                 return;
            }

            $data = array();
            $update_required = false; // Flag untuk cek apakah ada data yang dikirim untuk diupdate

            if (array_key_exists('title', $input_data)) {
                $data['title'] = $input_data['title'];
                $update_required = true;
            }
            if (array_key_exists('content', $input_data)) {
                $data['content'] = $input_data['content'];
                $update_required = true;
            }

            if (!$update_required) { // Jika tidak ada field 'title' atau 'content' di body
                 http_response_code(400);
                 echo json_encode(array('status' => false, 'message' => 'No valid data (title/content) provided for update.'));
                 return;
            }
            
            if ($this->note_model->update_note($id, $data)) {
                $updated_note = $this->note_model->get_note_by_id($id);
                http_response_code(200);
                echo json_encode(array('status' => true, 'message' => 'Note updated successfully.', 'data' => $updated_note));
            } else {
                 // Kemungkinan gagal karena error DB atau tidak ada perubahan
                $current_note_after_attempt = $this->note_model->get_note_by_id($id);
                if ($current_note_after_attempt && 
                    (!isset($data['title']) || $data['title'] === $current_note_after_attempt['title']) &&
                    (!isset($data['content']) || $data['content'] === $current_note_after_attempt['content'])
                ) {
                     http_response_code(200); 
                     echo json_encode(array('status' => true, 'message' => 'No changes detected or note already up to date.', 'data' => $current_note_after_attempt));
                } else {
                    http_response_code(500);
                    echo json_encode(array('status' => false, 'message' => 'Failed to update note.'));
                }
            }
        } elseif ($method === 'DELETE') {
            // Note sudah dipastikan ada dari pengecekan di atas
            if ($this->note_model->delete_note($id)) {
                http_response_code(200); // OK
                echo json_encode(array('status' => true, 'message' => 'Note deleted successfully.'));
            } else {
                http_response_code(500); // Internal Server Error
                echo json_encode(array('status' => false, 'message' => 'Failed to delete note from database.'));
            }
        } else {
            http_response_code(405); // Method Not Allowed
            echo json_encode(array('status' => false, 'message' => 'Method not allowed for this specific note ID.'));
        }
    }
}