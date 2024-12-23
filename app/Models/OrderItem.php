<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OrderItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'order_id',
        'product_id',
        'quantity',
        'unit_price',
        'subtotal',
    ];

    /**
     * Relasi ke tabel orders.
     */
    public function order()
    {
        return $this->belongsTo(Order::class);
    }
    
// OrderItem.php
public function product()
{
    return $this->belongsTo(Product::class, 'product_id');
}

    
}