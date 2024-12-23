-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 21 Des 2024 pada 14.16
-- Versi server: 10.4.28-MariaDB
-- Versi PHP: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `anisa-collection`
--

DELIMITER $$
--
-- Prosedur
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_best_selling_products` ()   BEGIN
    SELECT 
        p.id AS product_id,
        p.title AS product_name,
        SUM(oi.quantity) AS total_sold
    FROM products p
    JOIN order_items oi ON p.id = oi.product_id
    GROUP BY p.id, p.title
    ORDER BY total_sold DESC
    LIMIT 10;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_stock_by_category` (IN `p_category_id` BIGINT)   BEGIN
    SELECT p.id AS product_id, p.title AS product_name, p.stock
    FROM products p
    WHERE p.cat_id = p_category_id
    ORDER BY p.stock DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `restore_stock_on_cancel` (IN `order_id_param` BIGINT)   BEGIN
    -- Mulai transaksi
    START TRANSACTION;
    BEGIN
        -- Update stok produk langsung berdasarkan order_id
        UPDATE products p
        JOIN order_items oi ON p.id = oi.product_id
        SET p.stock = p.stock + oi.quantity
        WHERE oi.order_id = order_id_param;

        -- Cek apakah ada error dalam proses update
        IF ROW_COUNT() = 0 THEN
            -- Jika tidak ada baris yang terupdate, rollback transaksi
            ROLLBACK;
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock restore failed. No rows updated.';
        ELSE
            -- Jika berhasil, commit transaksi
            COMMIT;
        END IF;
    END;
END$$

--
-- Fungsi
--
CREATE DEFINER=`root`@`localhost` FUNCTION `CountActiveProducts` () RETURNS INT(11) DETERMINISTIC BEGIN
    DECLARE active_product_count INT DEFAULT 0;

    -- Menghitung jumlah produk dengan status active
    SELECT COUNT(*) INTO active_product_count
    FROM products
    WHERE status = 'active';

    RETURN active_product_count;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `total_income_in_period` (`start_date` DATE, `end_date` DATE) RETURNS DECIMAL(10,2) DETERMINISTIC BEGIN
    DECLARE total_income DECIMAL(10,2);

    SELECT SUM(total_amount) INTO total_income
    FROM orders
    WHERE status = 'finished'
      AND payment_status = 'sudah dibayar'
      AND created_at BETWEEN start_date AND end_date;

    RETURN IFNULL(total_income, 0);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `archived_orders`
--

CREATE TABLE `archived_orders` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `order_number` varchar(191) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `sub_total` double(8,2) NOT NULL,
  `total_amount` double(8,2) NOT NULL,
  `payment_method` enum('bayarditoko','transfer_bank') NOT NULL,
  `payment_status` enum('sudah dibayar','belum dibayar') NOT NULL,
  `status` enum('pending','process','finished','cancel') NOT NULL,
  `payment_proof` varchar(191) DEFAULT NULL,
  `first_name` varchar(191) NOT NULL,
  `last_name` varchar(191) NOT NULL,
  `email` varchar(191) NOT NULL,
  `phone` varchar(191) NOT NULL,
  `address` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `pickup_date` date DEFAULT NULL,
  `shipping_id` bigint(20) UNSIGNED DEFAULT NULL,
  `archived_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `brands`
--

CREATE TABLE `brands` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(191) NOT NULL,
  `slug` varchar(191) NOT NULL,
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `brands`
--

INSERT INTO `brands` (`id`, `title`, `slug`, `status`, `created_at`, `updated_at`) VALUES
(1, 'Sajiwa', 'sajiwa', 'active', '2024-12-17 21:42:23', '2024-12-17 21:42:23'),
(2, 'MDLY', 'mdly', 'active', '2024-12-17 21:42:33', '2024-12-17 21:42:33'),
(3, 'asyuramode', 'asyuramode', 'active', '2024-12-17 21:42:45', '2024-12-17 21:42:45'),
(4, 'ninos', 'ninos', 'active', '2024-12-17 21:42:59', '2024-12-17 21:42:59'),
(5, 'ninel co', 'ninel-co', 'active', '2024-12-17 21:43:12', '2024-12-17 21:43:12'),
(6, 'fadiyah', 'fadiyah', 'active', '2024-12-17 21:43:20', '2024-12-17 21:43:20'),
(7, 'Wardah', 'wardah', 'active', '2024-12-17 21:43:29', '2024-12-17 21:43:29'),
(8, 'ranola', 'ranola', 'active', '2024-12-17 21:43:43', '2024-12-17 21:43:43'),
(9, 'salvina', 'salvina', 'active', '2024-12-17 21:43:53', '2024-12-17 21:43:53'),
(10, 'Devino', 'devino', 'active', '2024-12-17 21:44:03', '2024-12-17 21:44:03'),
(13, 'Zalora', 'zalora', 'active', '2024-12-20 05:55:53', '2024-12-20 05:55:53');

-- --------------------------------------------------------

--
-- Struktur dari tabel `carts`
--

CREATE TABLE `carts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `order_id` bigint(20) UNSIGNED DEFAULT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `price` double(8,2) NOT NULL,
  `quantity` int(11) NOT NULL,
  `amount` double(8,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Trigger `carts`
--
DELIMITER $$
CREATE TRIGGER `after_insert_to_carts` AFTER INSERT ON `carts` FOR EACH ROW BEGIN
    -- Hapus data produk dari wishlist jika produk yang sama ditambahkan ke keranjang
    DELETE FROM wishlists
    WHERE product_id = NEW.product_id AND user_id = NEW.user_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `categories`
--

CREATE TABLE `categories` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(191) NOT NULL,
  `slug` varchar(191) NOT NULL,
  `summary` text DEFAULT NULL,
  `photo` varchar(191) DEFAULT NULL,
  `status` enum('active','inactive') NOT NULL DEFAULT 'inactive',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `categories`
--

INSERT INTO `categories` (`id`, `title`, `slug`, `summary`, `photo`, `status`, `created_at`, `updated_at`) VALUES
(1, 'Kemeja', 'kemeja', 'Kemeja berkualitas dengan desain modern dan bahan nyaman, cocok untuk gaya formal maupun kasual. Tersedia berbagai ukuran untuk melengkapi penampilan Anda.', '/storage/photos/5/Kemeja/default_kemeja.jpg', 'active', '2024-12-17 22:04:10', '2024-12-17 22:04:10'),
(2, 'Gamis', 'gamis', 'Gamis elegan dengan desain modis dan bahan berkualitas, memberikan kenyamanan dan keanggunan untuk berbagai kesempatan. Tersedia dalam beragam warna dan ukuran.', '/storage/photos/5/Gamis/gamis2_default.jpg', 'active', '2024-12-17 22:05:25', '2024-12-17 23:27:55'),
(3, 'Rok', 'rok', 'Rok stylish dengan beragam model dan bahan berkualitas, sempurna untuk tampilan santai hingga formal. Tersedia dalam berbagai warna dan ukuran.', '/storage/photos/5/Rok/default_rok.jpg', 'active', '2024-12-17 22:06:17', '2024-12-17 22:06:17'),
(4, 'Celana', 'celana', 'Celana stylish dan nyaman dengan berbagai model, bahan berkualitas, serta ukuran lengkap. Cocok untuk aktivitas sehari-hari hingga acara formal.', '/storage/photos/5/Celana/celana_default.jpg', 'active', '2024-12-17 22:42:11', '2024-12-17 22:42:11'),
(5, 'Kaos', 'kaos', 'Kaos stylish dengan bahan lembut dan nyaman, ideal untuk aktivitas santai sehari-hari. Pilihan desain dan warna kekinian untuk tampilan trendi', '/storage/photos/5/Kaos/kaos_deafault.jpg', 'active', '2024-12-17 23:07:16', '2024-12-17 23:07:16');

-- --------------------------------------------------------

--
-- Struktur dari tabel `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `queue` varchar(191) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) UNSIGNED NOT NULL,
  `reserved_at` int(10) UNSIGNED DEFAULT NULL,
  `available_at` int(10) UNSIGNED NOT NULL,
  `created_at` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `log_delete_orders`
--

CREATE TABLE `log_delete_orders` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `order_id` bigint(20) UNSIGNED NOT NULL,
  `deleted_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `log_delete_orders`
--

INSERT INTO `log_delete_orders` (`id`, `order_id`, `deleted_at`) VALUES
(4, 12, '2024-12-20 16:00:59'),
(5, 11, '2024-12-20 16:03:39');

--
-- Trigger `log_delete_orders`
--
DELIMITER $$
CREATE TRIGGER `prevent_log_orders_deletion` BEFORE DELETE ON `log_delete_orders` FOR EACH ROW BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Penghapusan data log tidak dapat dilakukan.';
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `log_delete_product`
--

CREATE TABLE `log_delete_product` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(191) NOT NULL,
  `price` double(8,2) NOT NULL,
  `stock` int(11) NOT NULL,
  `deleted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `action` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Trigger `log_delete_product`
--
DELIMITER $$
CREATE TRIGGER `prevent_log_product_deletion` BEFORE DELETE ON `log_delete_product` FOR EACH ROW BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Penghapusan data log tidak diperbolehkan untuk menjaga integritas data.';
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `messages`
--

CREATE TABLE `messages` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(191) NOT NULL,
  `subject` text NOT NULL,
  `email` varchar(191) NOT NULL,
  `photo` varchar(191) DEFAULT NULL,
  `phone` varchar(191) DEFAULT NULL,
  `message` longtext NOT NULL,
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `messages`
--

INSERT INTO `messages` (`id`, `name`, `subject`, `email`, `photo`, `phone`, `message`, `read_at`, `created_at`, `updated_at`) VALUES
(1, 'RIDWAN', 'Komentar Tentang Baju', 'ridwanadly@gmail.com', NULL, '082267821340', 'Baju yang di jual, bagus-bagus,  jarang ada di toko lain, sukak banget dehhh', '2024-12-18 05:26:04', '2024-12-18 04:06:01', '2024-12-18 05:26:04'),
(2, 'Jihad', 'Menanyakan Perihal Pengiriman Barang', 'jihad@gmail.com', NULL, '082267821340', 'Mengapa Barang saya cepat sekali sampai, padahal saya baru mesan di hari yang sama?', '2024-12-20 09:17:21', '2024-12-20 09:10:54', '2024-12-20 09:17:21');

-- --------------------------------------------------------

--
-- Struktur dari tabel `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(191) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(29, '2014_10_12_000000_create_users_table', 1),
(30, '2014_10_12_100000_create_password_resets_table', 1),
(31, '2019_08_19_000000_create_failed_jobs_table', 1),
(32, '2019_12_14_000001_create_personal_access_tokens_table', 1),
(33, '2020_07_10_021010_create_brands_table', 1),
(34, '2020_07_10_025334_create_banners_table', 1),
(35, '2020_07_10_112147_create_categories_table', 1),
(36, '2020_07_11_063857_create_products_table', 1),
(37, '2020_07_12_073132_create_post_categories_table', 1),
(38, '2020_07_12_073701_create_post_tags_table', 1),
(39, '2020_07_12_083638_create_posts_table', 1),
(40, '2020_07_13_151329_create_messages_table', 1),
(41, '2020_07_14_023748_create_shippings_table', 1),
(42, '2020_07_15_054356_create_orders_table', 1),
(43, '2020_07_15_102626_create_carts_table', 1),
(44, '2020_07_16_041623_create_notifications_table', 1),
(45, '2020_07_16_053240_create_coupons_table', 1),
(46, '2020_07_23_143757_create_wishlists_table', 1),
(47, '2020_07_24_074930_create_product_reviews_table', 1),
(48, '2020_07_24_131727_create_post_comments_table', 1),
(49, '2020_08_01_143408_create_settings_table', 1),
(50, '2023_06_21_164432_create_jobs_table', 1),
(51, '2024_11_15_053600_update_users_table', 1),
(52, '2024_11_16_072623_create_customers_table', 1),
(53, '2024_11_16_075431_drop_shipping_detail_table', 1),
(54, '2024_11_21_165722_remove_product_id_from_products_table', 1),
(55, '2024_11_21_170023_create_product_images_table', 1),
(56, '2024_11_21_170056_create_product_attributes_table', 1),
(57, '2024_11_21_170916_create_transactions_table', 1),
(58, '2024_11_21_171221_create_order_items_table', 1),
(59, '2024_11_21_171551_create_stocks_table', 1),
(60, '2024_11_21_171656_create_admins_table', 1),
(61, '2024_11_21_171834_create_sales_analysis_table', 1),
(62, '2024_11_21_171942_create_contact_messages_table', 1),
(63, '2024_11_21_172117_create_customer_loyalty_points_table', 1),
(64, '2024_11_21_172705_create_return_requests_table', 1),
(65, '2024_11_21_172932_create_sales_forecast_table', 1),
(66, '2024_11_21_173043_create_shipping_detail_table', 1),
(67, '2024_11_21_173331_create_reviews_table', 1),
(68, '2024_11_22_081815_add_email_to_admins_table', 1),
(69, '2024_12_04_034226_remove_status_from_carts_table', 2),
(70, '2024_12_04_040901_remove_shipping_foreign_key_from_orders_table', 3),
(71, '2024_12_06_175208_update_orders_table', 4),
(72, '2024_12_09_044640_update_orders2', 5),
(73, '2024_12_09_060811_add_payment_proof_to_orders_table', 6),
(74, '2024_12_09_135508_shippings_table', 7),
(75, '2024_12_09_175910_add_shipping_foreign_key_to_orders_table', 8),
(76, '2024_12_10_104356_add_address_to_orders_table', 9),
(77, '2024_12_10_104618_remove_country_and_postcode_from_orders_table', 10),
(78, '2024_12_10_155719_modify_address_column_in_orders_table', 10),
(79, '2024_12_11_101558_add_product_id_to_orders_table', 10);

-- --------------------------------------------------------

--
-- Struktur dari tabel `orders`
--

CREATE TABLE `orders` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `order_number` varchar(191) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `sub_total` double(8,2) NOT NULL,
  `coupon` double(8,2) DEFAULT NULL,
  `total_amount` double(8,2) NOT NULL,
  `payment_method` enum('bayarditoko','transfer_bank') NOT NULL DEFAULT 'bayarditoko',
  `payment_status` enum('sudah dibayar','belum dibayar') NOT NULL DEFAULT 'belum dibayar',
  `status` enum('pending','process','finished','cancel') NOT NULL DEFAULT 'pending',
  `payment_proof` varchar(191) DEFAULT NULL,
  `first_name` varchar(191) NOT NULL,
  `last_name` varchar(191) NOT NULL,
  `email` varchar(191) NOT NULL,
  `phone` varchar(191) NOT NULL,
  `address` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `pickup_date` date DEFAULT NULL,
  `shipping_id` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `orders`
--

INSERT INTO `orders` (`id`, `order_number`, `user_id`, `sub_total`, `coupon`, `total_amount`, `payment_method`, `payment_status`, `status`, `payment_proof`, `first_name`, `last_name`, `email`, `phone`, `address`, `created_at`, `updated_at`, `pickup_date`, `shipping_id`) VALUES
(1, 'ORD-UXLGTQVGSA', 6, 269000.00, NULL, 269000.00, 'bayarditoko', 'sudah dibayar', 'finished', NULL, 'RIDWAN', 'ADLY', 'ridwanadly@gmail.com', '082267821340', 'Medan Helvetia', '2024-12-17 22:54:33', '2024-12-17 22:56:03', '2024-12-20', NULL),
(2, 'ORD-LNCJ9ZWLR4', 6, 50000.00, NULL, 75000.00, 'transfer_bank', 'belum dibayar', 'pending', NULL, 'MHD RIDWAN', 'ADLY', 'ridwanadly@gmail.com', '082267821340', 'Medan Helvetia', '2024-12-17 23:52:17', '2024-12-17 23:52:17', NULL, 1),
(3, 'ORD-ACGFXXM9FU', 6, 269000.00, NULL, 294000.00, 'transfer_bank', 'belum dibayar', 'pending', NULL, 'ARMILA', 'SAKINAH', 'dana@gmail.com', '087654321234', 'SIBUHUAN', '2024-12-18 22:55:08', '2024-12-18 22:55:08', NULL, 1),
(4, 'ORD-TN2L2QL1DJ', 6, 269000.00, NULL, 319000.00, 'transfer_bank', 'belum dibayar', 'pending', NULL, 'ARMILA', 'SAKINAH', 'ridwanadly@gmail.com', '087654321234', 'jakarta', '2024-12-18 23:07:39', '2024-12-18 23:07:39', NULL, 3),
(5, 'ORD-TVWRIXUKKP', 6, 269000.00, NULL, 319000.00, 'transfer_bank', 'belum dibayar', 'pending', NULL, 'ARMILA', 'SAKINAH', 'ridwanadly@gmail.com', '087654321234', 'jakarta', '2024-12-18 23:13:01', '2024-12-18 23:13:01', NULL, 3),
(6, 'ORD-BXZPXO9QIU', 6, 150000.00, NULL, 150000.00, 'bayarditoko', 'belum dibayar', 'pending', NULL, 'MOHAMAD', 'RIFAA', 'ridwanadly@gmail.com', '087654321234', 'jakarta', '2024-12-18 23:24:33', '2024-12-18 23:24:33', '2024-12-24', NULL),
(7, 'ORD-UWAZKCC7TX', 10, 20000.00, NULL, 70000.00, 'transfer_bank', 'sudah dibayar', 'finished', 'payment_proofs/1734672209_Screenshot 2024-01-15 231914.png', 'Ahmad', 'Zaky', 'zaki@gmail.com', '082277515918', 'PADANGSIDIMPUAN', '2024-12-19 22:20:52', '2024-12-19 22:29:50', NULL, 3),
(8, 'ORD-1BLQLYGR66', 10, 20000.00, NULL, 20000.00, 'bayarditoko', 'belum dibayar', 'pending', NULL, 'Ahmad', 'Zaky', 'zaky@gmail.com', '082267821340', 'Jalan Mansyur', '2024-12-19 22:33:12', '2024-12-19 22:33:12', '2024-12-30', NULL),
(9, 'ORD-H8HF0HV2XR', 11, 50000.00, NULL, 75000.00, 'transfer_bank', 'belum dibayar', 'pending', 'payment_proofs/1734695235_Screenshot 2024-01-15 231900.png', 'Nisa', 'Siregar', 'nisa@gmail.com', '082267821340', 'Medan Tembung', '2024-12-20 04:46:14', '2024-12-20 04:47:15', NULL, 1),
(10, 'ORD-QLWYVTVKRB', 6, 50000.00, NULL, 100000.00, 'transfer_bank', 'sudah dibayar', 'finished', NULL, 'YENII', 'ZALUKHU', 'zahra@gmail.com', '087654321234', 'jakarta', '2024-12-20 05:33:40', '2024-12-20 05:35:14', NULL, 3),
(13, 'ORD-4G3BZZ4CZY', 12, 40000.00, NULL, 65000.00, 'transfer_bank', 'sudah dibayar', 'finished', 'payment_proofs/1734710838_☆ ͡ ݂ ۫  ᶻ 𝘇 𐰁 !.jpeg', 'Jihad', 'Sayyid', 'jihad@gmail.com', '082267821340', 'Medan Helvetia', '2024-12-20 09:04:34', '2024-12-20 09:52:17', NULL, 1),
(14, 'ORD-67659BC391AC42.36505010', NULL, 30800.00, NULL, 30800.00, 'bayarditoko', 'sudah dibayar', 'finished', NULL, 'Jihan', 'Azizah', 'jihan@gmail.com', '082267821340', 'Medan Helvetia', '2024-12-20 09:36:22', '2024-12-20 09:36:22', NULL, NULL),
(15, 'ORD-67659D6187F8E6.66938458', NULL, 169500.00, NULL, 169500.00, 'bayarditoko', 'sudah dibayar', 'finished', NULL, 'Fatimah', 'Zahra', 'zahra@gmail.com', '082267821340', 'Medan Helvetia', '2024-12-20 09:39:06', '2024-12-20 09:39:06', NULL, NULL);

--
-- Trigger `orders`
--
DELIMITER $$
CREATE TRIGGER `after_order_delete` AFTER DELETE ON `orders` FOR EACH ROW BEGIN
    INSERT INTO log_delete_orders (order_id, deleted_at)
    VALUES (OLD.id, NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_order_insert` AFTER INSERT ON `orders` FOR EACH ROW BEGIN
    -- Hapus data dari tabel carts untuk user yang melakukan checkout
    DELETE FROM carts
    WHERE user_id = NEW.user_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_order_update` AFTER UPDATE ON `orders` FOR EACH ROW BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO order_change_logs (order_id, user_id, action, old_value, new_value, created_at)
        VALUES (NEW.id, NEW.user_id, 'ubah status pesanan', OLD.status, NEW.status, NOW());
    END IF;

    IF OLD.payment_status <> NEW.payment_status THEN
        INSERT INTO order_change_logs (order_id, user_id, action, old_value, new_value, created_at)
        VALUES (NEW.id, NEW.user_id, 'ubah status pembayaran', OLD.payment_status, NEW.payment_status, NOW());
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `order_change_logs`
--

CREATE TABLE `order_change_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `order_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `action` varchar(255) NOT NULL,
  `old_value` text NOT NULL,
  `new_value` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `order_change_logs`
--

INSERT INTO `order_change_logs` (`id`, `order_id`, `user_id`, `action`, `old_value`, `new_value`, `created_at`) VALUES
(1, 7, 10, 'ubah status pesanan', 'pending', 'finished', '2024-12-20 05:29:50'),
(2, 7, 10, 'ubah status pembayaran', 'belum dibayar', 'sudah dibayar', '2024-12-20 05:29:50'),
(3, 10, 6, 'ubah status pesanan', 'pending', 'finished', '2024-12-20 12:35:14'),
(4, 10, 6, 'ubah status pembayaran', 'belum dibayar', 'sudah dibayar', '2024-12-20 12:35:14'),
(5, 13, 12, 'ubah status pesanan', 'pending', 'finished', '2024-12-20 16:52:17'),
(6, 13, 12, 'ubah status pembayaran', 'belum dibayar', 'sudah dibayar', '2024-12-20 16:52:17');

--
-- Trigger `order_change_logs`
--
DELIMITER $$
CREATE TRIGGER `prevent_order_change_log_deletion` BEFORE DELETE ON `order_change_logs` FOR EACH ROW BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Penghapusan data log perubahan pesanan tidak dapat dilakukan.';
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `order_items`
--

CREATE TABLE `order_items` (
  `order_item_id` bigint(20) UNSIGNED NOT NULL,
  `order_id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `quantity` int(11) NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `order_items`
--

INSERT INTO `order_items` (`order_item_id`, `order_id`, `product_id`, `quantity`, `unit_price`, `subtotal`, `created_at`, `updated_at`) VALUES
(1, 1, 19, 1, 269000.00, 269000.00, '2024-12-17 22:54:33', '2024-12-17 22:54:33'),
(2, 2, 24, 1, 50000.00, 50000.00, '2024-12-17 23:52:17', '2024-12-17 23:52:17'),
(3, 3, 19, 1, 269000.00, 269000.00, '2024-12-18 22:55:08', '2024-12-18 22:55:08'),
(4, 4, 19, 1, 269000.00, 269000.00, '2024-12-18 23:07:39', '2024-12-18 23:07:39'),
(5, 5, 19, 1, 269000.00, 269000.00, '2024-12-18 23:13:01', '2024-12-18 23:13:01'),
(6, 6, 20, 1, 150000.00, 150000.00, '2024-12-18 23:24:33', '2024-12-18 23:24:33'),
(7, 7, 25, 1, 20000.00, 20000.00, '2024-12-19 22:20:52', '2024-12-19 22:20:52'),
(8, 8, 23, 1, 20000.00, 20000.00, '2024-12-19 22:33:12', '2024-12-19 22:33:12'),
(9, 9, 24, 1, 50000.00, 50000.00, '2024-12-20 04:46:14', '2024-12-20 04:46:14'),
(10, 10, 24, 1, 50000.00, 50000.00, '2024-12-20 05:33:40', '2024-12-20 05:33:40'),
(13, 13, 25, 2, 20000.00, 40000.00, '2024-12-20 09:04:34', '2024-12-20 09:04:34'),
(14, 14, 1, 1, 30800.00, 30800.00, '2024-12-20 09:36:22', '2024-12-20 09:36:22'),
(15, 15, 2, 1, 169500.00, 169500.00, '2024-12-20 09:39:06', '2024-12-20 09:39:06');

-- --------------------------------------------------------

--
-- Struktur dari tabel `password_resets`
--

CREATE TABLE `password_resets` (
  `email` varchar(191) NOT NULL,
  `token` varchar(191) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `password_resets`
--

INSERT INTO `password_resets` (`email`, `token`, `created_at`) VALUES
('dana@gmail.com', '$2y$10$RcmifNHYH5sYOdY/6wBY6eMmOHz74ZFj7KLk/WIUG66JkPJlVlhA2', '2024-12-14 11:24:48');

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `payment_status_view`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `payment_status_view` (
`order_id` bigint(20) unsigned
,`order_number` varchar(191)
,`user_id` bigint(20) unsigned
,`payment_method` enum('bayarditoko','transfer_bank')
,`payment_status` enum('sudah dibayar','belum dibayar')
,`total_amount` double(8,2)
,`payment_proof` varchar(191)
,`order_date` timestamp
,`last_updated` timestamp
);

-- --------------------------------------------------------

--
-- Struktur dari tabel `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `tokenable_type` varchar(191) NOT NULL,
  `tokenable_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(191) NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `products`
--

CREATE TABLE `products` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(191) NOT NULL,
  `slug` varchar(191) NOT NULL,
  `description` longtext NOT NULL,
  `photo` text NOT NULL,
  `stock` int(11) NOT NULL DEFAULT 1,
  `size` varchar(191) DEFAULT 'M',
  `condition` enum('default','new','hot') NOT NULL DEFAULT 'default',
  `status` enum('active','inactive') NOT NULL DEFAULT 'inactive',
  `price` double(8,2) NOT NULL,
  `discount` double(8,2) DEFAULT NULL,
  `cat_id` bigint(20) UNSIGNED DEFAULT NULL,
  `brand_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `products`
--

INSERT INTO `products` (`id`, `title`, `slug`, `description`, `photo`, `stock`, `size`, `condition`, `status`, `price`, `discount`, `cat_id`, `brand_id`, `created_at`, `updated_at`) VALUES
(1, 'Kemeja Emma top tartan  kemeja crop Tartan Kotak-Kotak', 'kemeja-emma-top-tartan-kemeja-crop-tartan-kotak-kotak', '<p><span style=\"color: rgba(0, 0, 0, 0.8); font-family: Roboto, &quot;Helvetica Neue&quot;, Helvetica, Arial, 文泉驛正黑, &quot;WenQuanYi Zen Hei&quot;, &quot;Hiragino Sans GB&quot;, &quot;儷黑 Pro&quot;, &quot;LiHei Pro&quot;, &quot;Heiti TC&quot;, 微軟正黑體, &quot;Microsoft JhengHei UI&quot;, &quot;Microsoft JhengHei&quot;, sans-serif; font-size: 14px; white-space-collapse: preserve;\">EMMA TOP\r\nOVERSIZE 40.000 LENGAN BALON (LD -+115cm)\r\nALL SIZE 35.000 LENGAN KEMEJA (LD -+100cm)\r\nMaterial katun linent\r\nPanjang lengan -+60cm\r\nLingkar lengan -+40cm\r\nLingkar ketiak -+50cm\r\nPanjang baju -+47cm\r\nLingkar Dada -+105cm</span></p>', '/storage/photos/5/Kemeja/Kemeja Emma top tartan  kemeja crop Tartan Kotak-Kotak.jpg', 9, 'S,M,L,XL', 'new', 'active', 30800.00, 0.00, 1, 8, '2024-12-17 22:07:58', '2024-12-20 09:36:22'),
(2, 'Kemeja Wanita White Stripe Blouse Satin', 'kemeja-wanita-white-stripe-blouse-satin', '<p><span style=\"color: rgba(0, 0, 0, 0.8); font-family: Roboto, &quot;Helvetica Neue&quot;, Helvetica, Arial, 文泉驛正黑, &quot;WenQuanYi Zen Hei&quot;, &quot;Hiragino Sans GB&quot;, &quot;儷黑 Pro&quot;, &quot;LiHei Pro&quot;, &quot;Heiti TC&quot;, 微軟正黑體, &quot;Microsoft JhengHei UI&quot;, &quot;Microsoft JhengHei&quot;, sans-serif; font-size: 14px; white-space-collapse: preserve;\">71350 - White Stripe (S,M,L) \r\nS : shoulder 55 bust 124 length 70 \r\nM : shoulder 56 bust 128 length 71 \r\nL : shoulder 57 bust 132 length 73 \r\nReview : very good, soft : high, thick : medium, elastic : no </span></p>', '/storage/photos/5/Kemeja/Atasan Kemeja Wanita White Stripe Blouse Satin.jpg', 9, 'S,M,L,XL', 'new', 'active', 169500.00, 0.00, 1, 8, '2024-12-17 22:11:34', '2024-12-20 09:39:06'),
(3, 'Kemeja Garis-Garis Wanita Putih Biru', 'kemeja-garis-garis-wanita-putih-biru', '<p><span style=\"color: rgba(0, 0, 0, 0.8); font-family: Roboto, &quot;Helvetica Neue&quot;, Helvetica, Arial, 文泉驛正黑, &quot;WenQuanYi Zen Hei&quot;, &quot;Hiragino Sans GB&quot;, &quot;儷黑 Pro&quot;, &quot;LiHei Pro&quot;, &quot;Heiti TC&quot;, 微軟正黑體, &quot;Microsoft JhengHei UI&quot;, &quot;Microsoft JhengHei&quot;, sans-serif; font-size: 14px; white-space-collapse: preserve;\">DETAIL KEMEJA SALUR WANITA:\r\nMOHON DI BACA DULU DESKRIPSi\r\nKETIKAN INBOXSING MOHON DI FIDIOKAN DULU JIKA ADA KASALAHAN BARU DI KOMPLEN\r\n\r\nKEMEJA SALUR GARIS.GARIS,\r\nBAHAN RARON MOTIF ASLI REAL PICT\r\nMOTIF GARIS.GARIS\r\nLENGAN PANJANG\r\nPANJANG KEMEJA.63.CM.+\r\nKANCING FULL ATIF\r\nLENGAN KANCING\r\nDETAIL SIZE COCOKAN SAMA BERAT BADAN,\r\nSIZE. M. ld.100\r\nSIZE. L. ld. 105\r\nSIZE. XL. ld.11\r\nSIZE. XXL. ld. 115\r\nSIZE. 3XL.ld. 120\r\n1.kg.5.pcs KEMEJA\r\n\r\nBAHAN RAYON PREMIUM.\r\nBAHAN LEMBUT ADEM PASTI NYAMAN DI PAKAI TIDAK GEAIRAH\r\nCOCOK BUAT KULIAH DAN JUGA BUAT KEMANA.MANA</span></p>', '/storage/photos/5/Kemeja/Kemeja Garis-Garis Wanita Putih Biru.jpg', 10, '', 'new', 'active', 90000.00, 0.00, 1, 8, '2024-12-17 22:13:55', '2024-12-17 22:13:55'),
(4, 'Kemeja Kerja Wanita Putih Lengan panjang Ruffle White Black', 'kemeja-kerja-wanita-putih-lengan-panjang-ruffle-white-black', '<p><span style=\"color: rgba(0, 0, 0, 0.8); font-family: Roboto, &quot;Helvetica Neue&quot;, Helvetica, Arial, 文泉驛正黑, &quot;WenQuanYi Zen Hei&quot;, &quot;Hiragino Sans GB&quot;, &quot;儷黑 Pro&quot;, &quot;LiHei Pro&quot;, &quot;Heiti TC&quot;, 微軟正黑體, &quot;Microsoft JhengHei UI&quot;, &quot;Microsoft JhengHei&quot;, sans-serif; font-size: 14px; white-space-collapse: preserve;\">size(cm/inch)                   \r\nS: Length 58 / 22.8\"  Chest 86 / 33.9\"  Shoulder 35 / 13.8\"  Sleeve 58 / 22.8\"\r\nM: Length 59 / 23.2\"  Chest 90 / 35.4\"  Shoulder 36 / 14.2\"  Sleeve 59 / 23.2\"\r\nL: Length 60 / 23.6\"  Chest 94 / 37.0\"  Shoulder 37 / 14.6\"  Sleeve 60 / 23.6\"\r\nXL: Length 61 / 24.0\"  Chest 98 / 38.6\"  Shoulder 38 / 15.0\"  Sleeve 61 / 24.0\"</span></p>', '/storage/photos/5/Kemeja/Kemeja Kerja Wanita Putih Lengan panjang Ruffle White Black.jpg', 10, 'S,M,L,XL', 'new', 'active', 193000.00, 20.00, 1, 4, '2024-12-17 22:15:42', '2024-12-18 23:14:26'),
(5, 'Kemeja Purin Top Blouse Crop Two Tone Flanel Premium', 'kemeja-purin-top-blouse-crop-two-tone-flanel-premium', '<p><span style=\"color: rgba(0, 0, 0, 0.8); font-family: Roboto, &quot;Helvetica Neue&quot;, Helvetica, Arial, 文泉驛正黑, &quot;WenQuanYi Zen Hei&quot;, &quot;Hiragino Sans GB&quot;, &quot;儷黑 Pro&quot;, &quot;LiHei Pro&quot;, &quot;Heiti TC&quot;, 微軟正黑體, &quot;Microsoft JhengHei UI&quot;, &quot;Microsoft JhengHei&quot;, sans-serif; font-size: 14px; white-space-collapse: preserve;\">RINCIAN PRODUK\r\n🌸Bahan    : Wollycrepe Mix Katun Premium\r\n🌸Ukuran  : Allsize Fit L \r\n🌸Ld           : 100 – 102 cm\r\n🌸Toleransi Ukuran 1-2 cm </span></p>', '/storage/photos/5/Kemeja/Purin Top Blouse Crop Two Tone Flanel Premium.jpg', 10, 'S,M,L,XL', 'new', 'active', 42900.00, 0.00, 1, 4, '2024-12-17 22:18:06', '2024-12-17 22:18:06'),
(6, 'Gamis Brokat Simple Muslim', 'gamis-brokat-simple-muslim', '<p><span style=\"color: rgba(0, 0, 0, 0.8); font-family: Roboto, &quot;Helvetica Neue&quot;, Helvetica, Arial, 文泉驛正黑, &quot;WenQuanYi Zen Hei&quot;, &quot;Hiragino Sans GB&quot;, &quot;儷黑 Pro&quot;, &quot;LiHei Pro&quot;, &quot;Heiti TC&quot;, 微軟正黑體, &quot;Microsoft JhengHei UI&quot;, &quot;Microsoft JhengHei&quot;, sans-serif; font-size: 14px; white-space-collapse: preserve;\">Gamis merupakan sejenis baju kurung yang dominan digunakan di Timur Tengah dan negara-negara Islam. Baju ini di Arab disebut dengan Tsaub, disydasya, kandurah, juga qamis di Somalia.   \r\n\r\nspek couple ( l )  :bahan mostcrepe jait renda krancang mewah kombi tile lapis furing bagian bwah keliling ld 104cm pjg 135cm sleting blkg+kemeja mostcrepe ld102cm  (lengan tidak ad kancing)\r\n\r\nspek couple ( xl) : bahan mostcrepe jait renda krancang mewah kombi tile lapis furing bagian bwah keliling ld 110cm pjg 135cm sleting blkg+kemeja mostcrepe ld102cm\r\n\r\n\r\nspek maxi  (xl) : bahan mostcrepe jait renda krancang mewah kombi tile lapis furing bagian bwah keliling ld 110cm pjg 135cm sleting blkg\r\n\r\n\r\n\r\nspek maxi (l) : bahan mostcrepe jait renda krancang mewah kombi tile lapis furing bagian bwah keliling ld 104cm pjg 135cm sleting blkg\r\n\r\n\r\n\r\nspek maxi (m) :  bahan mostcrepe jait renda krancang mewah kombi tile lapis furing bagian bwah keliling ld 96 m pjg 135cm sleting blkg\r\n\r\n\r\nspek maxi (s): bahan mostcrepe jait renda krancang mewah kombi tile lapis furing bagian bwah keliling ld 84 m pjg 135cm sleting blkg</span></p>', '/storage/photos/5/Gamis/Gamis Brokat Simple Muslim.jpg', 10, 'S,M,L,XL', 'new', 'active', 129400.00, 0.00, 2, 7, '2024-12-17 22:20:19', '2024-12-17 22:24:10'),
(7, 'Gamis Muslim Dress Kotak Putih', 'gamis-muslim-dress-kotak-putih', '<p><span style=\"color: rgba(0, 0, 0, 0.8); font-family: Roboto, &quot;Helvetica Neue&quot;, Helvetica, Arial, 文泉驛正黑, &quot;WenQuanYi Zen Hei&quot;, &quot;Hiragino Sans GB&quot;, &quot;儷黑 Pro&quot;, &quot;LiHei Pro&quot;, &quot;Heiti TC&quot;, 微軟正黑體, &quot;Microsoft JhengHei UI&quot;, &quot;Microsoft JhengHei&quot;, sans-serif; font-size: 14px; white-space-collapse: preserve;\">Detail :\r\n- Bahan baju gamis remaja, ibu &amp; dewasa : 100% Katun Jepang Premium warna putih bersih\r\n- Adem, menyerap keringan, awet dan tahan lama\r\n- Kerah bulat dengan detail potongan dan renda pada bagian depan gamis\r\n- Kantong di kiri gamis\r\n- detail ujung tangan menggunakan karet (wudhu frendly)\r\n- Resleting di bagian belakang\r\n- Cocok untuk kegiatan keagamaan, pengajian, ramadhan, lebaran, manasik, haji dan kegiatan sehari-hari\r\n- Tersedia couple gamis anak putih dan sarimbit\r\n\r\n\r\nUkuran (centimeter) :\r\n(Panjang Baju x Lingkar Dada x Panjang Tangan)\r\n\r\n- S (130 x 96 x 55)\r\n- M (135 x 100 x 55)\r\n- L (140 x 104 x 57)\r\n- XL (140 x 110 x 58)\r\n- XXL (140 x 120 x 58)\r\n- XXXL (140 x 130 x 58)</span></p>', '/storage/photos/5/Gamis/Gamis Muslim Dress Kotak Putih.jpg', 10, 'S,M,L,XL', 'new', 'active', 245000.00, 0.00, 2, 7, '2024-12-17 22:22:13', '2024-12-17 22:22:13'),
(8, 'Gamis Muslim Putih Emas Mewah Premium', 'gamis-muslim-putih-emas-mewah-premium', '<p><span style=\"color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\">DETAIL:</span><br style=\"box-sizing: inherit; color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\"><span style=\"color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\">Bahan Luar: Cerutti Chiffon</span><br style=\"box-sizing: inherit; color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\"><span style=\"color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\">Bahan Furing: Asahi Premium</span><br style=\"box-sizing: inherit; color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\"><span style=\"color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\">Tekstur Bahan: bersifat adem, halus, lembut, ringan, dan jatuh (tidak kaku)</span><br style=\"box-sizing: inherit; color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\"><span style=\"color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\">Model Gamis dengan sleting di bagian belakang</span><br style=\"box-sizing: inherit; color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\"><span style=\"color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\">Kualitas jahitan, pola dan design yang premium sesuai standard EPC Designer Brand</span><br style=\"box-sizing: inherit; color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\"><br style=\"box-sizing: inherit; color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\"><span style=\"color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\">Panduan Ukuran Pakaian (dalam cm)</span><br style=\"box-sizing: inherit; color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\"><span style=\"color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\">Lingkar Dada / Lingkar Pinggang / Lingkar Panggul / Panjang Tangan / Panjang Baju</span><br style=\"box-sizing: inherit; color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\"><br style=\"box-sizing: inherit; color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\"><span style=\"color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\">Size S : 90 / 84 / 96 / 54 / 132</span><br style=\"box-sizing: inherit; color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\"><span style=\"color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\">Size M : 95 / 90 / 100 / 55 / 134</span><br style=\"box-sizing: inherit; color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\"><span style=\"color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\">Size L : 100 / 96 / 104 / 56 / 134</span><br style=\"box-sizing: inherit; color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\"><span style=\"color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\">Size XL : 106 / 100 / 108 / 57 / 135</span></p>', '/storage/photos/5/Gamis/Gamis Muslim Putih Emas Mewah Premium.jpg', 10, 'S,M,L,XL', 'new', 'active', 499500.00, 0.00, 2, 7, '2024-12-17 22:23:54', '2024-12-17 22:23:54'),
(9, 'Gamis Muslim Putih Motif Estetik Bunga', 'gamis-muslim-putih-motif-estetik-bunga', '<p><span style=\"color: rgba(0, 0, 0, 0.8); font-family: Roboto, &quot;Helvetica Neue&quot;, Helvetica, Arial, 文泉驛正黑, &quot;WenQuanYi Zen Hei&quot;, &quot;Hiragino Sans GB&quot;, &quot;儷黑 Pro&quot;, &quot;LiHei Pro&quot;, &quot;Heiti TC&quot;, 微軟正黑體, &quot;Microsoft JhengHei UI&quot;, &quot;Microsoft JhengHei&quot;, sans-serif; font-size: 14px; white-space-collapse: preserve;\">- Zipper bukaan belakang\r\n- Tali bagian pinggang\r\n- Pleats bagian bawah\r\n- Bahan: Premium Polly ringan ,tidak mudah kusut , menyerap keringat dengan baik sehingga tidak panas saat digunakan.\r\n</span></p><div><span style=\"color: rgba(0, 0, 0, 0.8); font-family: Roboto, &quot;Helvetica Neue&quot;, Helvetica, Arial, 文泉驛正黑, &quot;WenQuanYi Zen Hei&quot;, &quot;Hiragino Sans GB&quot;, &quot;儷黑 Pro&quot;, &quot;LiHei Pro&quot;, &quot;Heiti TC&quot;, 微軟正黑體, &quot;Microsoft JhengHei UI&quot;, &quot;Microsoft JhengHei&quot;, sans-serif; font-size: 14px; white-space-collapse: preserve;\"><br></span></div>', '/storage/photos/5/Gamis/Gamis Muslim Putih Motif Estetik Bunga.jpg', 9, 'S,M,L,XL', 'new', 'active', 749000.00, 0.00, 2, 7, '2024-12-17 22:26:11', '2024-12-17 22:26:11'),
(10, 'GAMIS BLESIA RUFFLE MAXI JUMBO', 'gamis-blesia-ruffle-maxi-jumbo', '<p><span style=\"color: rgba(0, 0, 0, 0.8); font-family: Roboto, &quot;Helvetica Neue&quot;, Helvetica, Arial, 文泉驛正黑, &quot;WenQuanYi Zen Hei&quot;, &quot;Hiragino Sans GB&quot;, &quot;儷黑 Pro&quot;, &quot;LiHei Pro&quot;, &quot;Heiti TC&quot;, 微軟正黑體, &quot;Microsoft JhengHei UI&quot;, &quot;Microsoft JhengHei&quot;, sans-serif; font-size: 14px; white-space-collapse: preserve;\">detail :\r\n- Model remple susun 4 tingkat\r\n- Ada resleting , BUSUI FRIENDLY\r\n- Tali Samping\r\n- Wudhu Friendy\r\n- lengan kerut \r\n- Bawah model umbrella </span></p>', '/storage/photos/5/Gamis/WhatsApp Image 2024-12-18 at 11.18.36_1c0ff8bf.jpg', 10, 'S,M,L,XL', 'new', 'active', 120000.00, 0.00, 2, 7, '2024-12-17 22:28:05', '2024-12-17 22:28:05'),
(11, 'Basic Skirt Korean Skirt Rok Linen Basic A Line Rok Payung', 'basic-skirt-korean-skirt-rok-linen-basic-a-line-rok-payung', '<p><span style=\"color: rgba(0, 0, 0, 0.8); font-family: Roboto, &quot;Helvetica Neue&quot;, Helvetica, Arial, 文泉驛正黑, &quot;WenQuanYi Zen Hei&quot;, &quot;Hiragino Sans GB&quot;, &quot;儷黑 Pro&quot;, &quot;LiHei Pro&quot;, &quot;Heiti TC&quot;, 微軟正黑體, &quot;Microsoft JhengHei UI&quot;, &quot;Microsoft JhengHei&quot;, sans-serif; font-size: 14px; white-space-collapse: preserve;\">material : premium pretty woman \r\nkarakteristik : tebal, tidak nerawang, tidak mudah kusut, adem dan flowly \r\n\r\npanjang : 98cm \r\nlebar keliling bawah : 260cm</span></p>', '/storage/photos/5/Rok/Basic Skirt Korean Skirt Rok Linen Basic A Line Rok Payung.jpg', 10, 'S,M,L,XL', 'new', 'active', 218000.00, 0.00, 3, 9, '2024-12-17 22:29:37', '2024-12-17 22:36:17'),
(12, 'Rok Cotton Twil Korean Skirt Style', 'rok-cotton-twil-korean-skirt-style', '<p><span style=\"color: rgba(0, 0, 0, 0.8); font-family: Roboto, &quot;Helvetica Neue&quot;, Helvetica, Arial, 文泉驛正黑, &quot;WenQuanYi Zen Hei&quot;, &quot;Hiragino Sans GB&quot;, &quot;儷黑 Pro&quot;, &quot;LiHei Pro&quot;, &quot;Heiti TC&quot;, 微軟正黑體, &quot;Microsoft JhengHei UI&quot;, &quot;Microsoft JhengHei&quot;, sans-serif; font-size: 14px; white-space-collapse: preserve;\">-Bahan katun Combed berkualitas\r\n-Polos dan berlipat di bagian bawah rok\r\n-Ornamen resleting pada bagian samping\r\n-Pilihan warna yang beragam untuk mix and match outfit Anda.\r\n-Pilihan ukuran Regular dan Plus Size, muat bb 45-70 kg\r\n==&gt; Size L Standar bb 45-55kg\r\n     - Lingkar Pinggang 65 cm melar sampai 95 cm\r\n     - Panjang Rok 90 cm\r\n==&gt; Size XL jumbo bb 56-70kg \r\n     - Lingkar Pinggang 70 cm melar sampai 100 cm\r\n     - Panjang Rok 92 cm</span></p>', '/storage/photos/5/Rok/Rok Cotton Twil Korean Skirt Style.jpg', 10, 'S,M,L,XL', 'new', 'active', 85000.00, 0.00, 3, 9, '2024-12-17 22:32:09', '2024-12-17 22:36:08'),
(13, 'Rok Hitam Maxi Smock Skirt', 'rok-hitam-maxi-smock-skirt', '<p><span style=\"color: rgba(0, 0, 0, 0.8); font-family: Roboto, &quot;Helvetica Neue&quot;, Helvetica, Arial, 文泉驛正黑, &quot;WenQuanYi Zen Hei&quot;, &quot;Hiragino Sans GB&quot;, &quot;儷黑 Pro&quot;, &quot;LiHei Pro&quot;, &quot;Heiti TC&quot;, 微軟正黑體, &quot;Microsoft JhengHei UI&quot;, &quot;Microsoft JhengHei&quot;, sans-serif; font-size: 14px; white-space-collapse: preserve;\">SARAS SKIRT (ROK KERUT)\r\nProduct Koleksi Elita Wear edisi \"\"Black &amp; White\"\" berbahan  ELITA Polyester\r\n\r\nKarakteristik bahan : \r\nBerbahan  ELITA Polyester yang halus dan flowy\r\nMemiliki cuttingan A dan detail pinggang full karet\r\nMemiliki detail saku samping\r\nMemiliki 3 ukuran yaitu petite, unisize dan upsize yang bisa kamu sesuaikan dengan ukuran tubuhmu dan juga bentuk badanmu</span></p>', '/storage/photos/5/Rok/Rok Hitam Maxi Smock Skirt.jpg', 9, 'S,M,L,XL', 'new', 'active', 115000.00, 0.00, 3, 10, '2024-12-17 22:34:25', '2024-12-17 22:35:54'),
(14, 'Rok Plisket Wanita Polos Basic Skirt Casual', 'rok-plisket-wanita-polos-basic-skirt-casual', '<p><span style=\"color: rgba(0, 0, 0, 0.8); font-family: Roboto, &quot;Helvetica Neue&quot;, Helvetica, Arial, 文泉驛正黑, &quot;WenQuanYi Zen Hei&quot;, &quot;Hiragino Sans GB&quot;, &quot;儷黑 Pro&quot;, &quot;LiHei Pro&quot;, &quot;Heiti TC&quot;, 微軟正黑體, &quot;Microsoft JhengHei UI&quot;, &quot;Microsoft JhengHei&quot;, sans-serif; font-size: 14px; white-space-collapse: preserve;\">Ukuran (CM) \r\n\r\n  Rok panjang:  90          ukuran pinggang:65 -110\r\n\r\nPengukuran manual dari 1-3CM deviasi adalah murni normal\r\n</span></p><div><span style=\"color: rgba(0, 0, 0, 0.8); font-family: Roboto, &quot;Helvetica Neue&quot;, Helvetica, Arial, 文泉驛正黑, &quot;WenQuanYi Zen Hei&quot;, &quot;Hiragino Sans GB&quot;, &quot;儷黑 Pro&quot;, &quot;LiHei Pro&quot;, &quot;Heiti TC&quot;, 微軟正黑體, &quot;Microsoft JhengHei UI&quot;, &quot;Microsoft JhengHei&quot;, sans-serif; font-size: 14px; white-space-collapse: preserve;\"><br></span></div>', '/storage/photos/5/Rok/Rok Plisket Wanita Polos Basic Skirt Casual.jpg', 10, 'S,M,L,XL', 'new', 'active', 46800.00, 0.00, 3, 10, '2024-12-17 22:35:44', '2024-12-17 22:35:44'),
(15, 'Rok Span Kerja Wanita Abu-Abu', 'rok-span-kerja-wanita-abu-abu', '<p><span style=\"color: rgba(0, 0, 0, 0.8); font-family: Roboto, &quot;Helvetica Neue&quot;, Helvetica, Arial, 文泉驛正黑, &quot;WenQuanYi Zen Hei&quot;, &quot;Hiragino Sans GB&quot;, &quot;儷黑 Pro&quot;, &quot;LiHei Pro&quot;, &quot;Heiti TC&quot;, 微軟正黑體, &quot;Microsoft JhengHei UI&quot;, &quot;Microsoft JhengHei&quot;, sans-serif; font-size: 14px; white-space-collapse: preserve;\">Kemiripan warna 95%, tergantung pencahayaan hp masing-masing\r\nBahan: Semi woll d.lamous\r\nPinggang ada tempat tali pinggang\r\nSize S-L5\r\n\r\nHarap pemesanan sesuai lingkar pinggang, bukan berdasarkan Berat BB\r\n\r\nUkuran standart =S M L XL\r\nLP=Lingkar pinggang\r\npjg=Panjang\r\nLB=Lingkar bawah\r\n\r\nS  :  LP 70 Cm, Pjg 93cm (BB 45-50kg)\r\nM :  LP 74 Cm, Pjg 93cm (BB 50-55kg)\r\nL  :  LP 78 Cm, Pig 93cm (BB 55-60kg)\r\nXL: LP 82 Cm, Pjg 93cm (BB 60-65kg)</span></p>', '/storage/photos/5/Rok/Rok Span Kerja Wanita Abu-Abu.jpg', 10, 'S,M,L,XL', 'new', 'active', 58500.00, 0.00, 3, 10, '2024-12-17 22:38:15', '2024-12-17 22:38:15'),
(16, 'Celana Karet Elastis Wanita Mulus Krem', 'celana-karet-elastis-wanita-mulus-krem', '<ul class=\"space-y-1\" style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ; list-style: none; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; padding: 0px; color: rgb(38, 38, 38); font-family: -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, Roboto, Helvetica, Arial, sans-serif, &quot;Apple Color Emoji&quot;, &quot;Segoe UI Emoji&quot;, &quot;Segoe UI Symbol&quot;; font-size: 14px;\"><li style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ; --tw-space-y-reverse: 0; margin-bottom: calc(.25rem * calc(1 - var(--tw-space-y-reverse))); margin-top: calc(.25rem * var(--tw-space-y-reverse));\"><span class=\"font-bold\" style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ; font-weight: 700;\">SKU</span><span style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ;\">:&nbsp;4B494AA9EDE243GS</span></li><li style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ; --tw-space-y-reverse: 0; margin-bottom: calc(.25rem * calc(1 - var(--tw-space-y-reverse))); margin-top: calc(.25rem * var(--tw-space-y-reverse));\"><span class=\"font-bold\" style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ; font-weight: 700;\">Warna</span><span style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ;\">:&nbsp;Coklat Olive</span></li><li style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ; --tw-space-y-reverse: 0; margin-bottom: calc(.25rem * calc(1 - var(--tw-space-y-reverse))); margin-top: calc(.25rem * var(--tw-space-y-reverse));\"><span class=\"font-bold\" style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ; font-weight: 700;\">Motif</span><span style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ;\">:&nbsp;Solid</span></li><li style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ; --tw-space-y-reverse: 0; margin-bottom: calc(.25rem * calc(1 - var(--tw-space-y-reverse))); margin-top: calc(.25rem * var(--tw-space-y-reverse));\"><span class=\"font-bold\" style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ; font-weight: 700;\">Panjang</span><span style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ;\">:&nbsp;Panjang</span></li><li style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ; --tw-space-y-reverse: 0; margin-bottom: calc(.25rem * calc(1 - var(--tw-space-y-reverse))); margin-top: calc(.25rem * var(--tw-space-y-reverse));\"><span class=\"font-bold\" style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ; font-weight: 700;\">Pinggang</span><span style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ;\">:&nbsp;Tengah Pinggang</span></li><li style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ;\"><span class=\"font-bold\" style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ; font-weight: 700;\">Gaya</span><span style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ;\">:&nbsp;Baju Santai|Basic|Modest</span></li></ul>', '/storage/photos/5/Celana/Celana Karet Elastis Wanita Mulus Krem.jpg', 10, 'S,M,L,XL', 'new', 'active', 239000.00, 0.00, 4, 5, '2024-12-17 22:44:31', '2024-12-17 22:44:31'),
(17, 'Celana Kulot Coullote Wanita Premium Linen Milo', 'celana-kulot-coullote-wanita-premium-linen-milo', '<p><span style=\"color: rgba(0, 0, 0, 0.8); font-family: Roboto, &quot;Helvetica Neue&quot;, Helvetica, Arial, 文泉驛正黑, &quot;WenQuanYi Zen Hei&quot;, &quot;Hiragino Sans GB&quot;, &quot;儷黑 Pro&quot;, &quot;LiHei Pro&quot;, &quot;Heiti TC&quot;, 微軟正黑體, &quot;Microsoft JhengHei UI&quot;, &quot;Microsoft JhengHei&quot;, sans-serif; font-size: 14px; white-space-collapse: preserve;\">Menggunakan bahan katu Linen rami yang adem dan tebal\r\nbahannya sangat nyaman dan tidak berbulu\r\nPinggang full karet anti begah\r\nEnak digunakan\r\n\r\nREALPICT\r\nGOOD QUALITY\r\n\r\nDETAIL UKURAN :\r\n  lingkar pinggang normal 62cm maksimal melar 110cm\r\n  lingkar paha 60cm\r\n  lingkar pinggul 112cm\r\n  lingkar kaki bawah 66cm\r\n  panjang 92cm</span></p>', '/storage/photos/5/Celana/Celana Kulot Coullote Wanita Premium Linen Milo.jpg', 10, 'S,M,L,XL', 'new', 'active', 65790.00, 0.00, 4, 5, '2024-12-17 22:45:47', '2024-12-17 22:45:47'),
(18, 'Celana Kulot Gantung Wanita Mulus Premium', 'celana-kulot-gantung-wanita-mulus-premium', '<p><span style=\"color: rgba(0, 0, 0, 0.8); font-family: Roboto, &quot;Helvetica Neue&quot;, Helvetica, Arial, 文泉驛正黑, &quot;WenQuanYi Zen Hei&quot;, &quot;Hiragino Sans GB&quot;, &quot;儷黑 Pro&quot;, &quot;LiHei Pro&quot;, &quot;Heiti TC&quot;, 微軟正黑體, &quot;Microsoft JhengHei UI&quot;, &quot;Microsoft JhengHei&quot;, sans-serif; font-size: 14px; white-space-collapse: preserve;\">- Ukuran lebar\r\n- Cuci dengan mesin dalam siklus reguler\r\n- Cuci dengan air panas dapat menyebabkan kerusakan pada serat kain\r\n- Untuk menghilangkan noda, beri sedikit sabun, rendam dalam air, diamkan sejenak, lalu kucek dengan lembut\r\n- Jangan diperas untuk membuang air berlebih\r\n- Setrika dengan pengaturan sedang untuk mencegah perubahan warna\r\n- Dibuat menggunakan bahan poly spandex rajut</span></p>', '/storage/photos/5/Celana/Celana Kulot Gantung Wanita Mulus Premium.jpg', 10, 'S,M,L,XL', 'new', 'active', 175000.00, 0.00, 4, 3, '2024-12-17 22:48:32', '2024-12-17 22:48:32');
INSERT INTO `products` (`id`, `title`, `slug`, `description`, `photo`, `stock`, `size`, `condition`, `status`, `price`, `discount`, `cat_id`, `brand_id`, `created_at`, `updated_at`) VALUES
(19, 'Celana Panjang Kantor Wanita Hitam', 'celana-panjang-kantor-wanita-hitam', '<ul class=\"space-y-1\" style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ; list-style: none; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; padding: 0px; color: rgb(38, 38, 38); font-family: -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, Roboto, Helvetica, Arial, sans-serif, &quot;Apple Color Emoji&quot;, &quot;Segoe UI Emoji&quot;, &quot;Segoe UI Symbol&quot;; font-size: 14px;\"><li style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ; --tw-space-y-reverse: 0; margin-bottom: calc(.25rem * calc(1 - var(--tw-space-y-reverse))); margin-top: calc(.25rem * var(--tw-space-y-reverse));\"><span class=\"font-bold\" style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ; font-weight: 700;\">SKU</span><span style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ;\">:&nbsp;38760AAECB73F2GS</span></li><li style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ; --tw-space-y-reverse: 0; margin-bottom: calc(.25rem * calc(1 - var(--tw-space-y-reverse))); margin-top: calc(.25rem * var(--tw-space-y-reverse));\"><span class=\"font-bold\" style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ; font-weight: 700;\">Warna</span><span style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ;\">:&nbsp;Black</span></li><li style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ; --tw-space-y-reverse: 0; margin-bottom: calc(.25rem * calc(1 - var(--tw-space-y-reverse))); margin-top: calc(.25rem * var(--tw-space-y-reverse));\"><span class=\"font-bold\" style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ; font-weight: 700;\">Motif</span><span style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ;\">:&nbsp;Solid</span></li><li style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ; --tw-space-y-reverse: 0; margin-bottom: calc(.25rem * calc(1 - var(--tw-space-y-reverse))); margin-top: calc(.25rem * var(--tw-space-y-reverse));\"><span class=\"font-bold\" style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ; font-weight: 700;\">Panjang</span><span style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ;\">:&nbsp;Crop</span></li><li style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ; --tw-space-y-reverse: 0; margin-bottom: calc(.25rem * calc(1 - var(--tw-space-y-reverse))); margin-top: calc(.25rem * var(--tw-space-y-reverse));\"><span class=\"font-bold\" style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ; font-weight: 700;\">Pinggang</span><span style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ;\">:&nbsp;Atas Pinggang</span></li><li style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ;\"><span class=\"font-bold\" style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ; font-weight: 700;\">Ukuran</span><span style=\"border: 0px solid rgb(229, 231, 235); --tw-border-spacing-x: 0; --tw-border-spacing-y: 0; --tw-translate-x: 0; --tw-translate-y: 0; --tw-rotate: 0; --tw-skew-x: 0; --tw-skew-y: 0; --tw-scale-x: 1; --tw-scale-y: 1; --tw-pan-x: ; --tw-pan-y: ; --tw-pinch-zoom: ; --tw-scroll-snap-strictness: proximity; --tw-gradient-from-position: ; --tw-gradient-via-position: ; --tw-gradient-to-position: ; --tw-ordinal: ; --tw-slashed-zero: ; --tw-numeric-figure: ; --tw-numeric-spacing: ; --tw-numeric-fraction: ; --tw-ring-inset: ; --tw-ring-offset-width: 0px; --tw-ring-offset-color: #fff; --tw-ring-color: rgba(59,130,246,.5); --tw-ring-offset-shadow: 0 0 #0000; --tw-ring-shadow: 0 0 #0000; --tw-shadow: 0 0 #0000; --tw-shadow-colored: 0 0 #0000; --tw-blur: ; --tw-brightness: ; --tw-contrast: ; --tw-grayscale: ; --tw-hue-rotate: ; --tw-invert: ; --tw-saturate: ; --tw-sepia: ; --tw-drop-shadow: ; --tw-backdrop-blur: ; --tw-backdrop-brightness: ; --tw-backdrop-contrast: ; --tw-backdrop-grayscale: ; --tw-backdrop-hue-rotate: ; --tw-backdrop-invert: ; --tw-backdrop-opacity: ; --tw-backdrop-saturate: ; --tw-backdrop-sepia: ;\">:&nbsp;Lurus</span></li></ul>', '/storage/photos/5/Celana/Celana Panjang Kantor Wanita Hitam.jpg', 5, 'S,M,L,XL', 'new', 'active', 269000.00, 0.00, 4, 3, '2024-12-17 22:50:02', '2024-12-18 23:13:01'),
(20, 'Celana Wanita Baggy Pants Jeans', 'celana-wanita-baggy-pants-jeans', '<p>Celana jeans baggy dengan bahan adem, mudah untuk dicuci dan tidak cepat luntur</p>', '/storage/photos/5/Celana/Celana Wanita Baggy Pants Jeans.jpg', 9, 'S,M,L,XL', 'new', 'active', 150000.00, 0.00, 4, 2, '2024-12-17 23:02:00', '2024-12-18 23:24:33'),
(21, 'Kaos wanita lengan panjang atasan wanita dewasa motif love', 'kaos-wanita-lengan-panjang-atasan-wanita-dewasa-motif-love', '<p><span style=\"color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\">Foto real hasil foto sendiri</span><br style=\"box-sizing: inherit; color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\"><span style=\"color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\">Bahan cattun</span><br style=\"box-sizing: inherit; color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\"><span style=\"color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\">Bahan adem dan lembut</span><br style=\"box-sizing: inherit; color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\"><span style=\"color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\">Nyaman untuk di pakai sehari hari</span><br style=\"box-sizing: inherit; color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\"><span style=\"color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\">Mudah menyerap keringat</span><br style=\"box-sizing: inherit; color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\"><span style=\"color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\">Ld 94cm</span><br style=\"box-sizing: inherit; color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\"><span style=\"color: rgb(33, 33, 33); font-family: &quot;Open Sauce One&quot;, sans-serif; font-size: 14px;\">Pj 71CM</span></p>', '/storage/photos/5/Kaos/Kaos wanita lengan panjang atasan wanita dewasa motif love.jpg', 10, 'S,M,L,XL', 'new', 'active', 32500.00, 0.00, 5, 6, '2024-12-17 23:09:46', '2024-12-17 23:09:46'),
(22, 'Kaos wanita lengan panjang GP crewneck t shirt', 'kaos-wanita-lengan-panjang-gp-crewneck-t-shirt', '<p><span style=\"color: rgba(0, 0, 0, 0.8); font-family: Roboto, &quot;Helvetica Neue&quot;, Helvetica, Arial, 文泉驛正黑, &quot;WenQuanYi Zen Hei&quot;, &quot;Hiragino Sans GB&quot;, &quot;儷黑 Pro&quot;, &quot;LiHei Pro&quot;, &quot;Heiti TC&quot;, 微軟正黑體, &quot;Microsoft JhengHei UI&quot;, &quot;Microsoft JhengHei&quot;, sans-serif; font-size: 14px; white-space-collapse: preserve;\">Produk Kaos Wanita terbaik 100% asli. Produk dibuat dengan Bahan yang nyaman digunakan, kualitas terbaik, desain trendy, update Kekinian. Membuat tampil percaya diri.\r\n\r\n☆ Size : XS - S - M - L - XL \r\n☆ Bahan: 60% Cotton - 40% Modal\r\n☆ Warna: Black - Navy - Olive - Black Stripe\r\n\r\nDetail size in cm: Lingkar Dada | Panjang\r\nXS : 70  | 63\r\nS   : 76  | 67\r\nM  : 80  | 70\r\nL   : 88  | 72\r\nXL : 104  | 75\r\n</span></p><div><span style=\"color: rgba(0, 0, 0, 0.8); font-family: Roboto, &quot;Helvetica Neue&quot;, Helvetica, Arial, 文泉驛正黑, &quot;WenQuanYi Zen Hei&quot;, &quot;Hiragino Sans GB&quot;, &quot;儷黑 Pro&quot;, &quot;LiHei Pro&quot;, &quot;Heiti TC&quot;, 微軟正黑體, &quot;Microsoft JhengHei UI&quot;, &quot;Microsoft JhengHei&quot;, sans-serif; font-size: 14px; white-space-collapse: preserve;\"><br></span></div>', '/storage/photos/5/Kaos/Kaos wanita lengan panjang GP crewneck t shirt.jpg', 10, 'S,M,L,XL', 'new', 'active', 59900.00, 0.00, 5, 6, '2024-12-17 23:13:48', '2024-12-17 23:13:48'),
(23, 'KAOS WANITA LENGAN PENDEK MOTIF KOTAK HITAM PUTIH', 'kaos-wanita-lengan-pendek-motif-kotak-hitam-putih', '<p>kainnya adem walaupun agak tipis, enak dipakai</p>', '/storage/photos/5/Kaos/KAOS WANITA LENGAN PENDEK MOTIF KOTAK HITAM PUTIH.jpg', 8, 'S,M,L,XL', 'new', 'active', 20000.00, 0.00, 5, 8, '2024-12-17 23:16:21', '2024-12-19 22:33:12'),
(24, 'Kaos Wanita Polos Hitam Premium Lengan Pendek', 'kaos-wanita-polos-hitam-premium-lengan-pendek', '<p><span style=\"color: rgba(0, 0, 0, 0.8); font-family: Roboto, &quot;Helvetica Neue&quot;, Helvetica, Arial, 文泉驛正黑, &quot;WenQuanYi Zen Hei&quot;, &quot;Hiragino Sans GB&quot;, &quot;儷黑 Pro&quot;, &quot;LiHei Pro&quot;, &quot;Heiti TC&quot;, 微軟正黑體, &quot;Microsoft JhengHei UI&quot;, &quot;Microsoft JhengHei&quot;, sans-serif; font-size: 14px; white-space-collapse: preserve;\">Bahan adem lembut ,menyerap keringat dan warna tidak mudah pudar \r\n</span></p><div><span style=\"color: rgba(0, 0, 0, 0.8); font-family: Roboto, &quot;Helvetica Neue&quot;, Helvetica, Arial, 文泉驛正黑, &quot;WenQuanYi Zen Hei&quot;, &quot;Hiragino Sans GB&quot;, &quot;儷黑 Pro&quot;, &quot;LiHei Pro&quot;, &quot;Heiti TC&quot;, 微軟正黑體, &quot;Microsoft JhengHei UI&quot;, &quot;Microsoft JhengHei&quot;, sans-serif; font-size: 14px; white-space-collapse: preserve;\"><br></span></div>', '/storage/photos/5/Kaos/Kaos Wanita Polos Hitam Premium Lengan Pendek.jpg', 6, 'S,M,L,XL', 'new', 'active', 50000.00, 0.00, 5, 1, '2024-12-17 23:19:06', '2024-12-20 05:35:14'),
(25, 'Kaos Wanita Polos Premium Lengan Pendek', 'kaos-wanita-polos-premium-lengan-pendek', '<p><span style=\"color: rgba(0, 0, 0, 0.8); font-family: Roboto, &quot;Helvetica Neue&quot;, Helvetica, Arial, 文泉驛正黑, &quot;WenQuanYi Zen Hei&quot;, &quot;Hiragino Sans GB&quot;, &quot;儷黑 Pro&quot;, &quot;LiHei Pro&quot;, &quot;Heiti TC&quot;, 微軟正黑體, &quot;Microsoft JhengHei UI&quot;, &quot;Microsoft JhengHei&quot;, sans-serif; font-size: 14px; white-space-collapse: preserve;\">Dapat digunakan Pria / Wanita, \r\n\r\n</span><span style=\"color: rgba(0, 0, 0, 0.8); font-family: Roboto, &quot;Helvetica Neue&quot;, Helvetica, Arial, 文泉驛正黑, &quot;WenQuanYi Zen Hei&quot;, &quot;Hiragino Sans GB&quot;, &quot;儷黑 Pro&quot;, &quot;LiHei Pro&quot;, &quot;Heiti TC&quot;, 微軟正黑體, &quot;Microsoft JhengHei UI&quot;, &quot;Microsoft JhengHei&quot;, sans-serif; font-size: 14px; white-space-collapse: preserve;\">M : 50cm X 70cm \r\n\r\nL : 52cm X 71cm \r\n\r\nXL: 54cm X 72 cm \r\n\r\nXXL: 58 CM X 72 CM </span><span style=\"color: rgba(0, 0, 0, 0.8); font-family: Roboto, &quot;Helvetica Neue&quot;, Helvetica, Arial, 文泉驛正黑, &quot;WenQuanYi Zen Hei&quot;, &quot;Hiragino Sans GB&quot;, &quot;儷黑 Pro&quot;, &quot;LiHei Pro&quot;, &quot;Heiti TC&quot;, 微軟正黑體, &quot;Microsoft JhengHei UI&quot;, &quot;Microsoft JhengHei&quot;, sans-serif; font-size: 14px; white-space-collapse: preserve;\">\r\n</span></p>', '/storage/photos/5/Kaos/Kaos Wanita Polos Premium Lengan Pendek.jpg', 2, 'S,M,L,XL', 'new', 'active', 20000.00, 0.00, 5, 1, '2024-12-17 23:21:09', '2024-12-20 09:52:17');

--
-- Trigger `products`
--
DELIMITER $$
CREATE TRIGGER `after_product_delete` AFTER DELETE ON `products` FOR EACH ROW BEGIN
    -- Menyisipkan data log penghapusan produk ke tabel log_delete_product
    INSERT INTO log_delete_product (product_id, title, price, stock, deleted_at, action)
    VALUES (
        OLD.id,                    -- ID produk yang dihapus
        OLD.title,                 -- Nama produk yang dihapus
        OLD.price,                 -- Harga produk yang dihapus
        OLD.stock,                 -- Stok produk yang dihapus
        NOW(),                     -- Waktu penghapusan
        'deleted'                  -- Tindakan penghapusan
    );
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_product_update` AFTER UPDATE ON `products` FOR EACH ROW BEGIN
    -- Cek jika ada perubahan pada stok
    IF OLD.stock <> NEW.stock THEN
        INSERT INTO product_change_logs (product_id, action, old_value, new_value, created_at)
        VALUES (NEW.id, 'ubah stok', OLD.stock, NEW.stock, NOW());
    END IF;

    -- Cek jika ada perubahan pada diskon
    IF OLD.discount <> NEW.discount THEN
        INSERT INTO product_change_logs (product_id, action, old_value, new_value, created_at)
        VALUES (NEW.id, 'ubah diskon', OLD.discount, NEW.discount, NOW());
    END IF;

    -- Cek jika ada perubahan pada harga
    IF OLD.price <> NEW.price THEN
        INSERT INTO product_change_logs (product_id, action, old_value, new_value, created_at)
        VALUES (NEW.id, 'ubah harga', OLD.price, NEW.price, NOW());
    END IF;

    -- Cek jika ada perubahan pada kondisi produk
    IF OLD.condition <> NEW.condition THEN
        INSERT INTO product_change_logs (product_id, action, old_value, new_value, created_at)
        VALUES (NEW.id, 'ubah kondisi produk', OLD.condition, NEW.condition, NOW());
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `product_change_logs`
--

CREATE TABLE `product_change_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `action` varchar(255) NOT NULL,
  `old_value` text NOT NULL,
  `new_value` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `product_change_logs`
--

INSERT INTO `product_change_logs` (`id`, `product_id`, `action`, `old_value`, `new_value`, `created_at`, `deleted_at`) VALUES
(1, 19, 'ubah stok', '6', '5', '2024-12-19 06:13:01', NULL),
(2, 4, 'ubah diskon', '0.00', '20.00', '2024-12-19 06:14:26', NULL),
(3, 20, 'ubah stok', '10', '9', '2024-12-19 06:24:33', NULL),
(4, 25, 'ubah stok', '10', '9', '2024-12-20 05:20:52', NULL),
(5, 25, 'ubah stok', '9', '8', '2024-12-20 05:29:50', NULL),
(6, 23, 'ubah stok', '9', '8', '2024-12-20 05:33:12', NULL),
(7, 24, 'ubah stok', '9', '8', '2024-12-20 11:46:14', NULL),
(8, 24, 'ubah stok', '8', '7', '2024-12-20 12:33:40', NULL),
(9, 24, 'ubah stok', '7', '6', '2024-12-20 12:35:14', NULL),
(10, 25, 'ubah stok', '8', '6', '2024-12-20 15:56:49', NULL),
(11, 25, 'ubah stok', '6', '4', '2024-12-20 16:04:34', NULL),
(12, 1, 'ubah stok', '10', '9', '2024-12-20 16:36:22', NULL),
(13, 2, 'ubah stok', '10', '9', '2024-12-20 16:39:06', NULL),
(14, 25, 'ubah stok', '4', '2', '2024-12-20 16:52:17', NULL);

--
-- Trigger `product_change_logs`
--
DELIMITER $$
CREATE TRIGGER `prevent_product_change_log_deletion` BEFORE DELETE ON `product_change_logs` FOR EACH ROW BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Penghapusan data log perubahan produk tidak dapat dilakukan.';
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `product_reviews`
--

CREATE TABLE `product_reviews` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `product_id` bigint(20) UNSIGNED DEFAULT NULL,
  `rate` tinyint(4) NOT NULL DEFAULT 0,
  `review` text DEFAULT NULL,
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `product_reviews`
--

INSERT INTO `product_reviews` (`id`, `user_id`, `product_id`, `rate`, `review`, `status`, `created_at`, `updated_at`) VALUES
(1, 6, 19, 5, 'Harga nya murah dan bahan kainnya adem , mantap la pokoknya', 'active', '2024-12-17 23:57:48', '2024-12-17 23:57:48'),
(2, 12, 25, 5, 'baju nya bagus banget, ga pernah nyesel beli di toko ini', 'active', '2024-12-20 09:55:00', '2024-12-20 09:55:00');

--
-- Trigger `product_reviews`
--
DELIMITER $$
CREATE TRIGGER `check_product_purchase_before_review` BEFORE INSERT ON `product_reviews` FOR EACH ROW BEGIN
    DECLARE product_purchased INT;

    -- Mengecek apakah user telah membeli produk tersebut
    SELECT COUNT(*) INTO product_purchased
    FROM orders o
    JOIN order_items oi ON o.id = oi.order_id
    WHERE o.user_id = NEW.user_id
    AND oi.product_id = NEW.product_id
    AND o.payment_status = 'sudah dibayar';

    -- Jika produk belum dibeli, batalkan penyisipan review
    IF product_purchased = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Anda hanya bisa mereview produk yang telah Anda beli.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `shippings`
--

CREATE TABLE `shippings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `type` varchar(191) NOT NULL,
  `price` decimal(8,2) NOT NULL,
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `shippings`
--

INSERT INTO `shippings` (`id`, `type`, `price`, `status`, `created_at`, `updated_at`) VALUES
(1, 'Medan Sekitar', 25000.00, 'active', '2024-12-17 23:50:10', '2024-12-17 23:50:10'),
(2, 'Medan - Binjai', 35000.00, 'active', '2024-12-17 23:50:25', '2024-12-17 23:50:25'),
(3, 'Medan - Deli Serdang', 50000.00, 'active', '2024-12-17 23:50:45', '2024-12-17 23:50:45');

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(191) NOT NULL,
  `email` varchar(191) DEFAULT NULL,
  `password` varchar(191) DEFAULT NULL,
  `photo` varchar(191) DEFAULT NULL,
  `role` enum('admin','user','kasir') NOT NULL DEFAULT 'user',
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password`, `photo`, `role`, `status`, `created_at`, `updated_at`) VALUES
(1, 'admin1', 'admin@gmail.com', '$2y$10$LLoezk1fsQpGS2ePvy4CpOqkR6z8YeWVA0suNfoSKiFYgCxNPYMYm', NULL, 'admin', 'active', '2024-12-03 15:59:05', '2024-12-12 02:54:08'),
(2, 'admin12', 'admin1@gmail.com', 'admin123', NULL, 'kasir', 'active', NULL, NULL),
(3, 'yenni', 'yenni@gmail.com', '$2y$10$d/xmO/6UcPHxIU8sUiuDHu6ASI20HWaDkN7R5oFugaRad3hYWIDFW', NULL, 'user', 'active', '2024-12-05 21:59:53', '2024-12-09 08:42:03'),
(4, 'kasir', 'kasir@gmail.com', '$2y$10$383s4wEXWJAa7COcQ4n4iug7Jm33Kz2b5ZpY8EhoWSX3oZWaQncJi', NULL, 'kasir', 'active', '2024-12-09 08:45:02', '2024-12-12 09:27:22'),
(5, 'dana', 'dana@gmail.com', '$2y$10$7.o9Rpq8ttf6JKZf6KRT1.4PRFpNQDlviLNuPbvysMYmQio/TA5UW', NULL, 'admin', 'active', '2024-12-13 20:13:05', '2024-12-13 20:13:05'),
(6, 'zahra', 'zahra@gmail.com', '$2y$10$AzsKOHw7jQcwmfP0WH6i5.w5XhP4h1GqUEZeLG5hYVqH3NNWS18si', NULL, 'user', 'active', '2024-12-13 20:28:27', '2024-12-13 20:28:27'),
(8, 'ridwan', 'ridwanadly@gmail.com', '$2y$10$zIM3lEs.mWweYMpaBqn/dOQx.4QavRtOqeptMCA6Z7tdwy/pkdfkG', NULL, 'kasir', 'active', '2024-12-13 20:31:21', '2024-12-13 20:31:21'),
(9, 'ilham', 'ilham@gmail.com', '$2y$10$2JscjVQCtRLZsThjSc45me7VuUb5UyKFn7mYBWwXB5HmAf9ejgbx6', NULL, 'user', 'active', '2024-12-15 11:14:18', '2024-12-15 11:14:18'),
(10, 'Ahmad', 'zaky@gmail.com', '$2y$10$XRKmRwNqnaQlHUjiDBfhUu/4bEgywIJwFLC6wf8R0Y4OpesyJet7e', NULL, 'user', 'active', '2024-12-19 22:19:09', '2024-12-19 22:19:09'),
(11, 'nisa', 'nisa@gmail.com', '$2y$10$FY0hBpBWcQXqJVNYVGED6ePIWUTNaFfhR8EbRejD1kEHqbF7SkDU6', '/storage/photos/11/🌥.jpeg', 'user', 'active', '2024-12-20 04:42:41', '2024-12-20 04:49:35'),
(12, 'jihad', 'jihad@gmail.com', '$2y$10$EmIYMgfTq05ZOCITZcBDzONAZow5OjhrOFqqdfPFknMHDmAnaNWqq', '/storage/photos/12/Screenshot 2024-01-15 231944.png', 'user', 'active', '2024-12-20 08:47:30', '2024-12-20 09:09:14');

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `view_discounted_products`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `view_discounted_products` (
`product_id` bigint(20) unsigned
,`product_title` varchar(191)
,`product_slug` varchar(191)
,`original_price` double(8,2)
,`discount_percentage` double(8,2)
,`discount_amount` double(19,2)
,`discounted_price` double(19,2)
,`product_stock` int(11)
,`product_created_at` timestamp
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `view_sales_summary`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `view_sales_summary` (
`product_id` bigint(20) unsigned
,`product_title` varchar(191)
,`total_sold` decimal(32,0)
,`total_sales_value` double(19,2)
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `v_orders_pickup`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `v_orders_pickup` (
`id` bigint(20) unsigned
,`order_number` varchar(191)
,`pickup_date` date
,`first_name` varchar(191)
,`last_name` varchar(191)
,`phone` varchar(191)
,`total_amount` double(8,2)
,`payment_method` enum('bayarditoko','transfer_bank')
,`status` enum('pending','process','finished','cancel')
);

-- --------------------------------------------------------

--
-- Struktur dari tabel `wishlists`
--

CREATE TABLE `wishlists` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `cart_id` bigint(20) UNSIGNED DEFAULT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `price` double(8,2) NOT NULL,
  `quantity` int(11) NOT NULL,
  `amount` double(8,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur untuk view `payment_status_view`
--
DROP TABLE IF EXISTS `payment_status_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `payment_status_view`  AS SELECT `o`.`id` AS `order_id`, `o`.`order_number` AS `order_number`, `o`.`user_id` AS `user_id`, `o`.`payment_method` AS `payment_method`, `o`.`payment_status` AS `payment_status`, `o`.`total_amount` AS `total_amount`, `o`.`payment_proof` AS `payment_proof`, `o`.`created_at` AS `order_date`, `o`.`updated_at` AS `last_updated` FROM `orders` AS `o` WHERE `o`.`payment_status` = 'sudah dibayar' ;

-- --------------------------------------------------------

--
-- Struktur untuk view `view_discounted_products`
--
DROP TABLE IF EXISTS `view_discounted_products`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_discounted_products`  AS SELECT `p`.`id` AS `product_id`, `p`.`title` AS `product_title`, `p`.`slug` AS `product_slug`, `p`.`price` AS `original_price`, `p`.`discount` AS `discount_percentage`, round(`p`.`price` * (`p`.`discount` / 100),2) AS `discount_amount`, round(`p`.`price` * (1 - `p`.`discount` / 100),2) AS `discounted_price`, `p`.`stock` AS `product_stock`, `p`.`created_at` AS `product_created_at` FROM `products` AS `p` WHERE `p`.`discount` > 0 AND `p`.`status` = 'active' ;

-- --------------------------------------------------------

--
-- Struktur untuk view `view_sales_summary`
--
DROP TABLE IF EXISTS `view_sales_summary`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_sales_summary`  AS SELECT `p`.`id` AS `product_id`, `p`.`title` AS `product_title`, sum(`oi`.`quantity`) AS `total_sold`, sum(`oi`.`quantity` * `p`.`price`) AS `total_sales_value` FROM ((`order_items` `oi` join `products` `p` on(`oi`.`product_id` = `p`.`id`)) join `orders` `o` on(`oi`.`order_id` = `o`.`id`)) WHERE `o`.`status` = 'finished' AND `o`.`payment_status` = 'sudah dibayar' AND `p`.`status` = 'active' GROUP BY `p`.`id`, `p`.`title` ;

-- --------------------------------------------------------

--
-- Struktur untuk view `v_orders_pickup`
--
DROP TABLE IF EXISTS `v_orders_pickup`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_orders_pickup`  AS SELECT `o`.`id` AS `id`, `o`.`order_number` AS `order_number`, `o`.`pickup_date` AS `pickup_date`, `o`.`first_name` AS `first_name`, `o`.`last_name` AS `last_name`, `o`.`phone` AS `phone`, `o`.`total_amount` AS `total_amount`, `o`.`payment_method` AS `payment_method`, `o`.`status` AS `status` FROM `orders` AS `o` WHERE `o`.`payment_method` = 'bayarditoko' AND `o`.`pickup_date` is not null AND `o`.`status` = 'pending' ORDER BY `o`.`pickup_date` ASC ;

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `brands`
--
ALTER TABLE `brands`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `brands_slug_unique` (`slug`);

--
-- Indeks untuk tabel `carts`
--
ALTER TABLE `carts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `carts_product_id_foreign` (`product_id`),
  ADD KEY `carts_user_id_foreign` (`user_id`),
  ADD KEY `carts_order_id_foreign` (`order_id`);

--
-- Indeks untuk tabel `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `categories_slug_unique` (`slug`);

--
-- Indeks untuk tabel `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indeks untuk tabel `log_delete_orders`
--
ALTER TABLE `log_delete_orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_id` (`order_id`);

--
-- Indeks untuk tabel `log_delete_product`
--
ALTER TABLE `log_delete_product`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indeks untuk tabel `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `orders_order_number_unique` (`order_number`),
  ADD KEY `orders_user_id_foreign` (`user_id`),
  ADD KEY `orders_shipping_id_foreign` (`shipping_id`);

--
-- Indeks untuk tabel `order_change_logs`
--
ALTER TABLE `order_change_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_id` (`order_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indeks untuk tabel `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`order_item_id`),
  ADD KEY `order_items_order_id_foreign` (`order_id`),
  ADD KEY `order_items_product_id_foreign` (`product_id`);

--
-- Indeks untuk tabel `password_resets`
--
ALTER TABLE `password_resets`
  ADD KEY `password_resets_email_index` (`email`);

--
-- Indeks untuk tabel `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`);

--
-- Indeks untuk tabel `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `products_slug_unique` (`slug`),
  ADD KEY `products_brand_id_foreign` (`brand_id`),
  ADD KEY `products_cat_id_foreign` (`cat_id`);

--
-- Indeks untuk tabel `product_change_logs`
--
ALTER TABLE `product_change_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indeks untuk tabel `product_reviews`
--
ALTER TABLE `product_reviews`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_reviews_user_id_foreign` (`user_id`),
  ADD KEY `product_reviews_product_id_foreign` (`product_id`);

--
-- Indeks untuk tabel `shippings`
--
ALTER TABLE `shippings`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`);

--
-- Indeks untuk tabel `wishlists`
--
ALTER TABLE `wishlists`
  ADD PRIMARY KEY (`id`),
  ADD KEY `wishlists_product_id_foreign` (`product_id`),
  ADD KEY `wishlists_user_id_foreign` (`user_id`),
  ADD KEY `wishlists_cart_id_foreign` (`cart_id`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `brands`
--
ALTER TABLE `brands`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT untuk tabel `carts`
--
ALTER TABLE `carts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT untuk tabel `categories`
--
ALTER TABLE `categories`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `log_delete_orders`
--
ALTER TABLE `log_delete_orders`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `log_delete_product`
--
ALTER TABLE `log_delete_product`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `messages`
--
ALTER TABLE `messages`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT untuk tabel `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=80;

--
-- AUTO_INCREMENT untuk tabel `orders`
--
ALTER TABLE `orders`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT untuk tabel `order_change_logs`
--
ALTER TABLE `order_change_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT untuk tabel `order_items`
--
ALTER TABLE `order_items`
  MODIFY `order_item_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT untuk tabel `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `products`
--
ALTER TABLE `products`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT untuk tabel `product_change_logs`
--
ALTER TABLE `product_change_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT untuk tabel `product_reviews`
--
ALTER TABLE `product_reviews`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT untuk tabel `shippings`
--
ALTER TABLE `shippings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT untuk tabel `wishlists`
--
ALTER TABLE `wishlists`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `carts`
--
ALTER TABLE `carts`
  ADD CONSTRAINT `carts_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `carts_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `carts_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `log_delete_product`
--
ALTER TABLE `log_delete_product`
  ADD CONSTRAINT `log_delete_product_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_shipping_id_foreign` FOREIGN KEY (`shipping_id`) REFERENCES `shippings` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `orders_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Ketidakleluasaan untuk tabel `order_change_logs`
--
ALTER TABLE `order_change_logs`
  ADD CONSTRAINT `order_change_logs_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `order_change_logs_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `order_items_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `order_items_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_brand_id_foreign` FOREIGN KEY (`brand_id`) REFERENCES `brands` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `products_cat_id_foreign` FOREIGN KEY (`cat_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL;

--
-- Ketidakleluasaan untuk tabel `product_change_logs`
--
ALTER TABLE `product_change_logs`
  ADD CONSTRAINT `product_change_logs_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `product_reviews`
--
ALTER TABLE `product_reviews`
  ADD CONSTRAINT `product_reviews_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `product_reviews_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Ketidakleluasaan untuk tabel `wishlists`
--
ALTER TABLE `wishlists`
  ADD CONSTRAINT `wishlists_cart_id_foreign` FOREIGN KEY (`cart_id`) REFERENCES `carts` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `wishlists_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `wishlists_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

DELIMITER $$
--
-- Event
--
CREATE DEFINER=`root`@`localhost` EVENT `archive_old_orders` ON SCHEDULE EVERY 1 DAY STARTS '2024-12-20 01:06:55' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
    INSERT INTO archived_orders (
        id, order_number, user_id, sub_total, total_amount,
        payment_method, payment_status, status, payment_proof, first_name,
        last_name, email, phone, address, created_at, updated_at,
        pickup_date, shipping_id
    )
    SELECT
        id, order_number, user_id, sub_total, total_amount,
        payment_method, payment_status, status, payment_proof, first_name,
        last_name, email, phone, address, created_at, updated_at,
        pickup_date, shipping_id
    FROM orders
    WHERE (status = 'finished' OR status = 'cancel')
        AND created_at < NOW() - INTERVAL 1 YEAR;
    DELETE FROM orders
    WHERE (status = 'finished' OR status = 'cancel')
        AND created_at < NOW() - INTERVAL 1 YEAR;
END$$

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
