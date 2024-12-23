<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

class UpdateOrdersTable extends Migration
{
    public function up()
    {
        Schema::table('orders', function (Blueprint $table) {
            if (!Schema::hasColumn('orders', 'pickup_date')) {
                $table->date('pickup_date')->nullable();
            }
        
            // Modifikasi kolom lainnya
            $table->enum('payment_method', ['bayarditoko', 'transfer_bank'])->default('bayarditoko')->change();
            $table->enum('payment_status', ['sudah dibayar', 'belum dibayar'])->default('belum dibayar')->change();
            $table->enum('status', ['pending', 'process', 'finished', 'cancel'])->default('pending')->change();
        });
        
    }

    public function down()
    {
        Schema::table('orders', function (Blueprint $table) {
            // Restore dropped columns

            
 

           
          
        });
    }
}
