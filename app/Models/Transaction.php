<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Transaction extends Model
{
    use HasFactory;

    // Menggunakan transaction_id sebagai primary key
    protected $primaryKey = 'transaction_id'; 

    protected $fillable = [
        'transaction_id',
        'customer_id',
        'transaction_date',
        'total_amount',
        'status',
    ];

    public function customer()
    {
        return $this->belongsTo(Customer::class, 'customer_id', 'customer_id');
    }
}
