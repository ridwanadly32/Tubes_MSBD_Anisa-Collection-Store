<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class ModifyAddressColumnInOrdersTable extends Migration
{
    public function up()
    {
        // Schema::table('orders', function (Blueprint $table) {
  
            
        //     // Tambahkan kolom address dengan tipe string dan tidak nullable
        //     $table->string('address')->after('phone'); // Sesuaikan dengan posisi kolom yang diinginkan
        // });
    }

    public function down()
    {
        // Schema::table('orders', function (Blueprint $table) {
        //     // Jika rollback, kembalikan kolom address ke tipe text dan nullable
        //     $table->text('address')->nullable()->after('phone');
        // });
    }
}
