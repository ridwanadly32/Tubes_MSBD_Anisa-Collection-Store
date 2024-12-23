<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateTransactionsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    // public function up()
    // {
    //     if (!Schema::hasTable('transactions')) { // Tambahkan validasi ini
    //         Schema::create('transactions', function (Blueprint $table) {
    //             $table->id('transaction_id'); // Kolom transaction_id sebagai primary key dan auto-increment

    //             $table->unsignedBigInteger('customer_id'); // Kolom customer_id tanpa AUTO_INCREMENT
    //             $table->dateTime('transaction_date'); // Kolom transaction_date
    //             $table->decimal('total_amount', 10, 2); // Kolom total_amount dengan 10 digit, 2 angka desimal
    //             $table->enum('status', ['Pending', 'Completed', 'Cancelled']); // Kolom status dengan enum

    //             // Menambahkan foreign key constraint
    //             $table->foreign('customer_id')->references('customer_id')->on('customers')->onDelete('cascade');

    //             $table->timestamps(); // Kolom created_at dan updated_at
    //         });
    //     }
    // }

    // /**
    //  * Reverse the migrations.
    //  *
    //  * @return void
    //  */
    // public function down()
    // {
    //     Schema::dropIfExists('transactions');
    // }
}
