<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateOrderItemsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('order_items', function (Blueprint $table) {
            $table->id('order_item_id'); // Kolom order_item_id sebagai primary key dengan auto-increment
            $table->unsignedBigInteger('order_id'); // Kolom order_id sebagai foreign key ke orders
            $table->unsignedBigInteger('product_id'); // Kolom product_id sebagai foreign key ke products
            $table->integer('quantity'); // Kolom quantity untuk jumlah produk yang dipesan
            $table->decimal('unit_price', 10, 2); // Kolom unit_price dengan 10 digit dan 2 angka desimal
            $table->decimal('subtotal', 10, 2); // Kolom subtotal (harga * quantity)
            $table->timestamps(); // Kolom created_at dan updated_at

            // Menambahkan foreign key constraint
            $table->foreign('order_id')->references('id')->on('orders')->onDelete('cascade');
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
        Schema::dropIfExists('order_items');
    }
}
