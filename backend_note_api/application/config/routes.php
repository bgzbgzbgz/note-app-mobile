<?php
defined('BASEPATH') OR exit('No direct script access allowed');

$route['default_controller'] = 'welcome';
$route['404_override'] = '';
$route['translate_uri_dashes'] = FALSE;

// --- API Routes for Notes ---
// Menggunakan controller 'Api.php'

// Untuk method GET (semua notes) dan POST (create note)
// Akan diarahkan ke controller 'Api' dan method 'index'
$route['api/notes'] = 'api/index'; // Menggunakan controller 'Api'

// Untuk method GET (satu note by ID), PUT (update note by ID), DELETE (delete note by ID)
// Akan diarahkan ke controller 'Api' dan method 'note', dengan ID sebagai parameter
$route['api/notes/(:num)'] = 'api/note/$1'; // Menggunakan controller 'Api'