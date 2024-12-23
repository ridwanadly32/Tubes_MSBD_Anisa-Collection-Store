<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateReviewsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('reviews', function (Blueprint $table) {
            $table->id(); // Kolom id sebagai primary key dengan auto-increment
            $table->unsignedBigInteger('user_id'); // Kolom user_id sebagai foreign key ke users
            $table->unsignedBigInteger('product_id'); // Kolom product_id sebagai foreign key ke products
            $table->unsignedBigInteger('order_item_id'); // Kolom order_item_id sebagai foreign key ke order_items
            $table->integer('rating')->comment('Rating from 1-5'); // Kolom rating dengan penjelasan
            $table->text('comment')->nullable(); // Kolom comment untuk review, bisa kosong
            $table->text('images')->nullable()->comment('Comma-separated URLs of review images'); // Kolom images dengan catatan
            $table->integer('likes_count')->default(0); // Kolom likes_count dengan default 0
            $table->boolean('is_verified_purchase')->default(false)->comment('Indicates if review is from verified purchase'); // Kolom is_verified_purchase
            $table->enum('status', ['pending', 'approved', 'rejected'])->default('pending'); // Kolom status dengan default 'pending'
            $table->text('admin_response')->nullable(); // Kolom admin_response untuk respons admin
            $table->timestamps(); // Kolom created_at dan updated_at

            // Menambahkan foreign key constraint
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            $table->foreign('product_id')->references('id')->on('products')->onDelete('cascade');
            $table->foreign('order_item_id')->references('order_item_id')->on('order_items')->onDelete('cascade');

            // Menambahkan index
            $table->index(['user_id', 'product_id'], 'idx_user_product_review');
            $table->index('product_id', 'idx_product_reviews');
            $table->index('rating', 'idx_review_rating');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('reviews');
    }
}
