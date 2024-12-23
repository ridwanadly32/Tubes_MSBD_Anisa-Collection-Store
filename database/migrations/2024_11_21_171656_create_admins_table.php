<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateAdminsTable extends Migration
{
    // /**
    //  * Run the migrations.
    //  *
    //  * @return void
    //  */
    // public function up()
    // {
    //     Schema::create('admins', function (Blueprint $table) {
    //         $table->id('admin_id'); // Kolom admin_id sebagai primary key dengan auto-increment
    //         $table->string('username', 50); // Kolom username dengan panjang maksimal 50 karakter
    //         $table->string('password_hash', 255); // Kolom password_hash untuk menyimpan hash password
    //         $table->enum('role', ['Admin', 'Cashier']); // Kolom role dengan enum 'Admin' dan 'Cashier'
    //         $table->timestamps(); // Kolom created_at dan updated_at
    //     });
    // }

    // /**
    //  * Reverse the migrations.
    //  *
    //  * @return void
    //  */
    // public function down()
    // {
    //     Schema::dropIfExists('admins');
    // }
}
