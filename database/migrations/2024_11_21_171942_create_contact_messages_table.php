<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateContactMessagesTable extends Migration
{
    // /**
    //  * Run the migrations.
    //  *
    //  * @return void
    //  */
    // public function up()
    // {
    //     Schema::create('contact_messages', function (Blueprint $table) {
    //         $table->id('message_id'); // Kolom message_id sebagai primary key dengan auto-increment
    //         $table->string('customer_name', 255); // Kolom customer_name untuk nama pelanggan
    //         $table->string('phone', 20); // Kolom phone untuk nomor telepon pelanggan
    //         $table->string('email', 255); // Kolom email untuk alamat email pelanggan
    //         $table->text('message_content'); // Kolom message_content untuk isi pesan
    //         $table->dateTime('date_sent'); // Kolom date_sent untuk menyimpan tanggal dan waktu pesan dikirim
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
    //     Schema::dropIfExists('contact_messages');
    // }
}
