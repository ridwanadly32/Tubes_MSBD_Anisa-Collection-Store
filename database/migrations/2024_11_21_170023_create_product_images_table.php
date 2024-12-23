<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateProductImagesTable extends Migration
{
    // /**
    //  * Run the migrations.
    //  *
    //  * @return void
    //  */
    // public function up()
    // {
    //     Schema::create('product_images', function (Blueprint $table) {
    //         $table->id(); // Kolom id (primary key)
    //         $table->unsignedBigInteger('product_id'); // Kolom product_id (foreign key)
    //         $table->string('image_url', 255); // Kolom image_url
    //         $table->boolean('is_primary')->default(false); // Kolom is_primary
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
    //     Schema::dropIfExists('product_images');
    // }
}
