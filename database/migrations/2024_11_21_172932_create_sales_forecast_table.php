<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateSalesForecastTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    // public function up()
    // {
    //     Schema::create('sales_forecast', function (Blueprint $table) {
    //         $table->id('forecast_id'); // Kolom forecast_id sebagai primary key dengan auto-increment
    //         $table->unsignedBigInteger('product_id'); // Kolom product_id sebagai foreign key ke products
    //         $table->date('forecast_date'); // Kolom forecast_date untuk tanggal perkiraan penjualan
    //         $table->integer('forecast_quantity'); // Kolom forecast_quantity untuk jumlah perkiraan penjualan

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
    //     Schema::dropIfExists('sales_forecast');
    // }
}
