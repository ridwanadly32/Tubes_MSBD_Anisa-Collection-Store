<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddAddressToOrdersTable extends Migration
{
    public function up()
    {
        // Schema::table('orders', function (Blueprint $table) {
        //     $table->text('address')->nullable()->after('phone'); // Tambahkan kolom address
        //     $table->dropColumn('address1'); // Hapus address1
        //     $table->dropColumn('address2'); // Hapus address2
        // });
    }

    public function down()
    {
        // Schema::table('orders', function (Blueprint $table) {
        //     $table->text('address1')->nullable();
        //     $table->text('address2')->nullable();
        //     $table->dropColumn('address');
        // });
    }
}
