<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateSalesAnalysisTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    // public function up()
    // {
    //     Schema::create('sales_analysis', function (Blueprint $table) {
    //         $table->id('analysis_id'); // Kolom analysis_id sebagai primary key dengan auto-increment
    //         $table->unsignedBigInteger('product_id'); // Kolom product_id sebagai foreign key ke products
    //         $table->date('sales_date'); // Kolom sales_date untuk menyimpan tanggal penjualan
    //         $table->integer('sales_quantity'); // Kolom sales_quantity untuk jumlah produk terjual
    //         $table->decimal('total_sales_amount', 10, 2); // Kolom total_sales_amount dengan 10 digit, 2 angka desimal

    //         // Menambahkan foreign key constraint
    //         $table->foreign('product_id')->references('id')->on('products')->onDelete('cascade');

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
    //     Schema::dropIfExists('sales_analysis');
    // }
}
