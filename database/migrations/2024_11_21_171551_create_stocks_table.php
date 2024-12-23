<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateStocksTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('stocks', function (Blueprint $table) {
            $table->id('stock_id'); // Kolom stock_id sebagai primary key dengan auto-increment
            $table->unsignedBigInteger('product_id'); // Kolom product_id sebagai foreign key ke products
            $table->string('location', 100); // Kolom location untuk menyimpan lokasi produk
            $table->integer('quantity'); // Kolom quantity untuk jumlah produk di lokasi
            $table->string('location_name', 100); // Kolom location_name untuk nama lokasi
            $table->dateTime('last_updated'); // Kolom last_updated untuk tanggal dan waktu terakhir update stok
            $table->timestamps(); // Kolom created_at dan updated_at

            // Menambahkan foreign key constraint
            $table->foreign('product_id')->references('id')->on('products')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('stocks');
    }
}
