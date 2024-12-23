<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ViewSalesSummary extends Model
{
    // Tentukan nama tabel sebagai view
    protected $table = 'view_sales_summary';

    // Nonaktifkan timestamps jika tidak diperlukan
    public $timestamps = false;

    // Tentukan kolom yang dapat diakses
    protected $fillable = [
        'product_id',
        'product_title',
        'total_sold',
        'total_sales_value'
    ];
}
