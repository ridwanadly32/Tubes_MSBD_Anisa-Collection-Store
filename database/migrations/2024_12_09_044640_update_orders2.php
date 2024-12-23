<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class UpdateOrders2 extends Migration
{
    public function up()
    {
        Schema::table('orders', function (Blueprint $table) {
            // Cek apakah kolom sudah ada sebelum menambahkannya
            if (!Schema::hasColumn('orders', 'pickup_date')) {
                $table->date('pickup_date')->nullable();
            }
        });
    }

    public function down()
    {
        Schema::table('orders', function (Blueprint $table) {
            // Jangan hapus kolom pickup_date jika sudah digunakan oleh migrasi lain
            if (Schema::hasColumn('orders', 'pickup_date')) {
                $table->dropColumn('pickup_date');
            }
        });
    }
}
