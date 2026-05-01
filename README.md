# VinUniDatathon


````markdown
# Datathon 2026 - Round 1

Repository này chứa bài làm cho Datathon 2026 Round 1, gồm 4 phần chính: SQL, EDA, Forecasting và báo cáo tổng hợp.

## 1. Cấu trúc thư mục

```text
.
├── part1_sql/
│   ├── .gitkeep
│   └── CauHoiTracNghiem.sql
│
├── part2_eda/
│   ├── .gitkeep
│   └── EDA.ipynb
│
├── part3_forecasting/
│   ├── dataset/
│   │   └── các file CSV đã clean
│   ├── .gitkeep
│   ├── Model_final.ipynb
│   └── submission_direct.csv
│
├── report/
│   ├── .gitkeep
│   └── report.pdf
│
└── README.md
````

## 2. Mô tả nội dung

### `part1_sql/`

Chứa file SQL cho phần truy vấn dữ liệu.

### `part2_eda/`

Chứa notebook phân tích khám phá dữ liệu, kiểm tra dữ liệu đầu vào và các thống kê mô tả phục vụ quá trình phân tích.

### `part3_forecasting/`

Chứa notebook xây dựng mô hình dự báo `Revenue` và `COGS`.

Các nội dung chính trong notebook:

* Đọc bộ dữ liệu đã clean từ thư mục `dataset/`.
* Xây dựng đặc trưng từ dữ liệu thời gian, traffic, inventory, orders, promotions, returns, reviews, leakage và profit datamart.
* Huấn luyện mô hình LightGBM.
* So sánh recursive forecasting và direct forecasting.
* Tạo file submission cuối cùng.

File submission chính:

```text
part3_forecasting/submission_direct.csv
```

### `report/`

Chứa báo cáo tổng hợp cuối cùng của bài làm.

## 3. Yêu cầu môi trường

Khuyến nghị sử dụng Python 3.10 trở lên.

Cài các thư viện cần thiết:

```bash
pip install pandas numpy matplotlib scikit-learn lightgbm notebook
```

Nếu repository được clone từ GitHub và có dùng Git LFS để lưu file dữ liệu lớn, cần chạy thêm:

```bash
git lfs install
git lfs pull
```

## 4. Cách chạy mô hình forecasting

Notebook chính nằm tại:

```text
part3_forecasting/Model_final.ipynb
```

Dữ liệu đầu vào nằm tại:

```text
part3_forecasting/dataset/
```

Notebook sử dụng relative path:

```python
BASE_DIR = Path.cwd()
DATA_DIR = BASE_DIR / "dataset"
```

Vì vậy, cần mở và chạy notebook trong đúng thư mục `part3_forecasting/`.

### Các bước chạy

Di chuyển vào thư mục forecasting:

```bash
cd part3_forecasting
```

Mở notebook:

```bash
jupyter notebook Model_final.ipynb
```

Sau đó chạy toàn bộ notebook:

```text
Kernel → Restart & Run All
```

Sau khi chạy xong, file kết quả sẽ được tạo hoặc cập nhật tại:

```text
part3_forecasting/submission_direct.csv
```

## 5. Ghi chú về dữ liệu

Dữ liệu trong `part3_forecasting/dataset/` là bộ dữ liệu đã được clean và chuẩn hóa trước khi đưa vào mô hình.

Các file dữ liệu chính gồm:

```text
sales.csv
sample_submission.csv
web_traffic.csv
inventory.csv
orders.csv
order_items.csv
promotions.csv
returns.csv
reviews.csv
leakage_datamart.csv
profit_datamart.csv
```

Một số file dữ liệu có kích thước lớn nên được quản lý bằng Git LFS.

## 6. File submission

File submission chính là:

```text
part3_forecasting/submission_direct.csv
```

File gồm đúng 3 cột:

```text
Date, Revenue, COGS
```

## 7. Ghi chú tái lập

Notebook cố định random seed:

```python
RANDOM_SEED = 42
```

Toàn bộ đường dẫn dữ liệu được thiết lập bằng relative path, giúp notebook có thể chạy lại trên máy khác miễn là giữ đúng cấu trúc thư mục.

```
```
