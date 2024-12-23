<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateReturnRequestsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('return_requests', function (Blueprint $table) {
            $table->id('return_id'); // Kolom return_id sebagai primary key dengan auto-increment
            $table->unsignedBigInteger('transaction_id'); // Kolom transaction_id sebagai foreign key ke transactions
            $table->unsignedBigInteger('product_id'); // Kolom product_id sebagai foreign key ke products
            $table->integer('quantity'); // Kolom quantity untuk jumlah produk yang dikembalikan
            $table->text('reason'); // Kolom reason untuk alasan pengembalian produk
            $table->timestamps(); // Kolom created_at dan updated_at

            // Menambahkan foreign key constraint
            $table->foreign('transaction_id')->references('transaction_id')->on('transactions')->onDelete('cascade');
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
        Schema::dropIfExists('return_requests');
    }
}
