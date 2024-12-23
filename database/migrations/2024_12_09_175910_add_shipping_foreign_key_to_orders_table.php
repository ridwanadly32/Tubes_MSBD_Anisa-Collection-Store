<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddShippingForeignKeyToOrdersTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('orders', function (Blueprint $table) {
            // Menambahkan kolom shipping_id
            $table->unsignedBigInteger('shipping_id')->nullable();

            // Menambahkan foreign key yang menghubungkan ke tabel shippings
            $table->foreign('shipping_id')->references('id')->on('shippings')->onDelete('SET NULL');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('orders', function (Blueprint $table) {
            // Menghapus foreign key
            $table->dropForeign(['shipping_id']);
            // Menghapus kolom shipping_id
            $table->dropColumn('shipping_id');
        });
    }
}
