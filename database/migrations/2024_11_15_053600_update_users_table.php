<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class UpdateUsersTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('users', function (Blueprint $table) {
            // Menambahkan kolom baru
            Schema::table('users', function (Blueprint $table) {
                if (!Schema::hasColumn('users', 'phone_number')) { // Cek apakah kolom sudah ada
                    $table->string('phone_number', 191)->nullable();
                }
            });
            

            // Memodifikasi kolom enum 'role'
            $table->enum('role', ['admin', 'user', 'kasir'])->default('user')->change();
// 
            // Menghapus kolom yang tidak diperlukan
            if (Schema::hasColumn('users', 'provider')) {
                $table->dropColumn('provider');
            }
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        
    }
}
