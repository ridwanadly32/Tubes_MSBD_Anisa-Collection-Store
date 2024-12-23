<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class VOrdersPickup extends Model
{
    protected $table = 'v_orders_pickup'; // Nama view di database
    public $timestamps = false; // Tidak memiliki timestamps

    protected $fillable = [
        'id',
        'order_number',
        'pickup_date',
        'first_name',
        'last_name',
        'phone',
        'total_amount',
        'payment_method',
        'status',
    ];
}
