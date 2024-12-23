<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class RemoveStatusFromCartsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('carts', function (Blueprint $table) {
            $table->dropColumn('status'); // Menghapus kolom status
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        // Jika migration di-revert, tambahkan kolom status kembali
        Schema::table('carts', function (Blueprint $table) {
            $table->enum('status', ['new', 'progress', 'delivered', 'cancel'])->default('new');
        });
    }
}
