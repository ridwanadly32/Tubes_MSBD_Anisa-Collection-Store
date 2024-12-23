<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateProductAttributesTable extends Migration
{
    // /**
    //  * Run the migrations.
    //  *
    //  * @return void
    //  */
    // public function up()
    // {
    //     Schema::create('product_attributes', function (Blueprint $table) {
    //         $table->id(); // Kolom id (primary key)
    //         $table->unsignedBigInteger('product_id'); // Kolom product_id (foreign key)
    //         $table->string('size', 10)->nullable(); // Kolom size
    //         $table->string('color', 50)->nullable(); // Kolom color
    //         $table->string('material', 50)->nullable(); // Kolom material
    //         $table->timestamps(); // Kolom created_at dan updated_at

    //         // Menambahkan foreign key constraint
    //         $table->foreign('product_id')->references('id')->on('products')->onDelete('cascade');

    //     });
    // }

    // /**
    //  * Reverse the migrations.
    //  *
    //  * @return void
    //  */
    // public function down()
    // {
    //     Schema::dropIfExists('product_attributes');
    // }
}
