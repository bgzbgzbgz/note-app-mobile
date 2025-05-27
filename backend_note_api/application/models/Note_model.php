<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Note_model extends CI_Model {

    private $table = 'notes'; // Sesuaikan dengan nama tabel catatan di database-mu

    public function __construct() {
        parent::__construct();
        $this->load->database(); // Memuat library database CodeIgniter
    }

    /**
     * Mengambil semua catatan dari database.
     * @return array Array berisi semua catatan, atau array kosong jika tidak ada.
     */
    public function get_notes() { // PASTIKAN NAMA METHOD INI BENAR
        $query = $this->db->get($this->table);
        if ($query->num_rows() > 0) {
            return $query->result_array(); // Mengembalikan hasil sebagai array asosiatif
        }
        return array(); // Kembalikan array kosong jika tidak ada data
    }

    /**
     * Mengambil satu catatan berdasarkan ID.
     * @param int $id ID catatan.
     * @return array|false Data catatan jika ditemukan, atau false jika tidak.
     */
    public function get_note_by_id($id) {
        $query = $this->db->get_where($this->table, array('id' => $id));
        if ($query->num_rows() > 0) {
            return $query->row_array(); // Mengembalikan satu baris hasil
        }
        return false;
    }

    /**
     * Menyimpan catatan baru ke database.
     * @param array $data Data catatan yang akan disimpan (asosiatif array, key adalah nama kolom).
     * @return int|false ID dari catatan yang baru dimasukkan, atau false jika gagal.
     */
    public function insert_note($data) {
        // Tambahkan timestamp jika kolom created_at dan updated_at ada dan tidak dihandle otomatis oleh DB
        if (!isset($data['created_at']) && $this->db->field_exists('created_at', $this->table)) {
            $data['created_at'] = date('Y-m-d H:i:s');
        }
        if (!isset($data['updated_at']) && $this->db->field_exists('updated_at', $this->table)) {
            $data['updated_at'] = date('Y-m-d H:i:s');
        }

        $this->db->insert($this->table, $data);
        if ($this->db->affected_rows() > 0) {
            return $this->db->insert_id(); // Mengembalikan ID auto-increment
        }
        return false;
    }

    /**
     * Memperbarui catatan yang ada di database.
     * @param int $id ID catatan yang akan diperbarui.
     * @param array $data Data baru untuk catatan (asosiatif array).
     * @return bool True jika berhasil, false jika gagal atau tidak ada yang berubah.
     */
    public function update_note($id, $data) {
        // Tambahkan timestamp updated_at jika ada kolomnya dan tidak dihandle otomatis oleh DB
        if (!isset($data['updated_at']) && $this->db->field_exists('updated_at', $this->table)) {
            $data['updated_at'] = date('Y-m-d H:i:s');
        }

        $this->db->where('id', $id);
        $this->db->update($this->table, $data);
        return $this->db->affected_rows() >= 0; // Kembalikan true jika berhasil atau tidak ada perubahan
                                               // (affected_rows() bisa 0 jika data sama)
                                               // Jika ingin lebih ketat (hanya true jika ada perubahan), gunakan > 0
    }

    /**
     * Menghapus catatan dari database.
     * @param int $id ID catatan yang akan dihapus.
     * @return bool True jika berhasil, false jika gagal.
     */
    public function delete_note($id) {
        $this->db->where('id', $id);
        $this->db->delete($this->table);
        return $this->db->affected_rows() > 0;
    }
}