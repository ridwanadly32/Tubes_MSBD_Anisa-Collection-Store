<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddProductIdToOrdersTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('orders', function (Blueprint $table) {
            // Tambahkan kolom product_id
            $table->unsignedBigInteger('product_id')->nullable()->after('id');

            // Tambahkan foreign key constraint
            $table->foreign('product_id')
                  ->references('id')
                  ->on('products')
                  ->onDelete('SET NULL') // Atur product_id menjadi NULL jika produk dihapus
                  ->onUpdate('CASCADE'); // Update foreign key jika id produk berubah
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
            // Hapus foreign key constraint
            $table->dropForeign(['product_id']);

            // Hapus kolom product_id
            $table->dropColumn('product_id');
        });
    }
}
