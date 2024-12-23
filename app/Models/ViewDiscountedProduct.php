<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ViewDiscountedProduct extends Model
{
    // Tentukan nama tabel sebagai view
    protected $table = 'view_discounted_products';

    // Nonaktifkan timestamps jika tidak ada
    public $timestamps = false;

    // Tentukan kolom yang dapat diakses
    protected $fillable = [
        'product_id',
        'product_title',
        'product_slug',
        'original_price',
        'discount_percentage', // Kolom untuk persen diskon
        'discount_amount',      // Kolom untuk nilai diskon dalam rupiah
        'discounted_price',
        'product_stock',
        'product_created_at'
    ];
}
