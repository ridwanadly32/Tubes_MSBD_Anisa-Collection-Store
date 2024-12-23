<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class RemoveCountryAndPostcodeFromOrdersTable extends Migration
{
    public function up()
    {
        // Schema::table('orders', function (Blueprint $table) {
        //     // Menghapus kolom country dan post_code
        //     $table->dropColumn('country');
        //     $table->dropColumn('post_code');
        // });
    }

    public function down()
    {
        // Schema::table('orders', function (Blueprint $table) {
        //     // Menambahkan kembali kolom country dan post_code jika dibutuhkan
        //     $table->string('country')->nullable();
        //     $table->string('post_code')->nullable();
        // });
    }
}
