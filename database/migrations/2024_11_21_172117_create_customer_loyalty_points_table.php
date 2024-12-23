<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateCustomerLoyaltyPointsTable extends Migration
{
    // /**
    //  * Run the migrations.
    //  *
    //  * @return void
    //  */
    // public function up()
    // {
    //     Schema::create('customer_loyalty_points', function (Blueprint $table) {
    //         $table->id('loyalty_id'); // Kolom loyalty_id sebagai primary key dengan auto-increment
    //         $table->unsignedBigInteger('customer_id'); // Kolom customer_id sebagai foreign key ke customers
    //         $table->integer('point'); // Kolom point untuk menyimpan jumlah poin loyalti

    //         // Menambahkan foreign key constraint
    //         $table->foreign('customer_id')->references('customer_id')->on('customers')->onDelete('cascade');

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
    //     Schema::dropIfExists('customer_loyalty_points');
    // }
}
