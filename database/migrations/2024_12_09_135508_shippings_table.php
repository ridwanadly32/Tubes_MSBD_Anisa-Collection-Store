<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class ShippingsTable extends Migration
{
    public function up()
    {
        // Periksa apakah tabel 'shippings' sudah ada sebelum membuatnya
        if (!Schema::hasTable('shippings')) {
            Schema::create('shippings', function (Blueprint $table) {
                $table->id();
                $table->string('type');
                $table->decimal('price', 8, 2);
                $table->enum('status', ['active', 'inactive'])->default('active');
                $table->timestamps();
            });
        }
    }

    public function down()
    {
        Schema::dropIfExists('shippings');
    }
}
