Bạn là một Senior Mobile Engineer + Product Designer.
Hãy giúp tôi xây dựng một ứng dụng **quản lý chi tiêu cá nhân OFFLINE** (không cần backend), sử dụng **Flutter + Cubit (Bloc)**.

---

# 🎯 1. MỤC TIÊU ỨNG DỤNG

Xây dựng app:

* Quản lý thu nhập, chi tiêu, tích luỹ
* Theo dõi theo tháng
* Có gợi ý thông minh giúp nhập nhanh
* Tập trung vào trải nghiệm: **nhập cực nhanh, ít thao tác, thông minh**

---

# 🧱 2. KIẾN TRÚC CHUNG

* Flutter
* State Management: Cubit (Bloc)
* Local Database:

  * SQLite (sqflite) hoặc Hive
* Clean Architecture (optional):

  * feature-based structure

---

# 🧩 3. DOMAIN MODELS

Tạo các model sau:

## 3.1 IncomeSource

* id
* name (Lương, OT, đầu tư...)
* amount
* date

---

## 3.2 Budget (Quỹ chi tiêu)

* id
* name (Ăn uống, xăng xe...)
* limitAmount
* spentAmount
* month

---

## 3.3 Saving (Tích luỹ)

* id
* name (Quỹ khẩn cấp, mua xe...)
* totalAmount
* targetAmount
* createdAt

---

## 3.4 FixedExpense

* id
* name (tiền nhà, điện...)
* amount
* isPaid
* dueDate
* paidFrom (source/budget)

---

## 3.5 Transaction (CORE)

* id
* type (income | expense | transfer)
* amount
* category
* subCategory
* from
* to
* date
* note

---

## 3.6 Wallet

* totalBalance

---

# 🏠 4. HOME SCREEN

Hiển thị:

## 4.1 Tổng quan

* Balance
* Tổng thu tháng
* Tổng chi tháng

---

## 4.2 Nguồn thu (Income Sources)

* danh sách:

  * Lương tháng
  * OT
* click:

  * xem lịch sử
  * xem đã phân bổ đi đâu

---

## 4.3 Tích luỹ (Saving)

* tổng tiền tích luỹ
* biểu đồ theo tháng
* click:

  * xem chi tiết
  * progress goal

---

## 4.4 Quỹ chi tiêu (Budgets)

* hiển thị:

  * Ăn uống: 3.2tr / 4tr (progress bar)
* click:

  * xem danh sách transaction

---

## 4.5 Chi tiêu cố định (Fixed Expenses)

* checkbox:

  * đã thanh toán / chưa
* khi tick:

  * chọn nguồn tiền trích

---

# ➕ 5. ADD FLOW (NHẬP GIAO DỊCH)

## 5.1 Chọn loại:

* Thu nhập
* Chi tiêu
* Chuyển tiền

---

## 5.2 Nhập dữ liệu:

* amount
* category
* thời gian
* note

---

## 5.3 Smart Input (QUAN TRỌNG)

* nhập text:

  * “ăn sáng 30k”
    → auto parse:
  * category
  * amount

---

# ⚡ 6. QUICK INPUT SYSTEM (TÍNH NĂNG CHÍNH)

Thiết kế hệ thống nhập nhanh với các lớp sau:

---

## 6.1 Gợi ý theo thời gian

* Sáng:

  * Ăn sáng, cafe
* Trưa:

  * Ăn trưa
* Tối:

  * Ăn tối

---

## 6.2 Gợi ý theo lịch sử

* hiển thị:

  * 5 giao dịch gần nhất
  * giao dịch hay dùng

---

## 6.3 Gợi ý theo thói quen

* học từ user:

  * giờ nào hay tiêu gì
* ưu tiên hiển thị theo tần suất

---

## 6.4 Smart Chips UI

Hiển thị:

* 🔥 Most likely (độ tin cậy cao nhất)
* ⚡ Quick actions
* 🔁 Recent
* ⌨ Input text

---

## 6.5 Smart Amount Suggestion

* hiển thị:

  * 25k • 30k • 35k
* dựa trên lịch sử

---

## 6.6 Zero Input Mode

* nếu hệ thống đoán chắc:

  * hiển thị:

    * “Bạn vừa uống cafe 30k?”
    * [✔ Đúng] [Sửa]

---

## 6.7 Bulk Input

* parse:

  * “cafe 30k, ăn trưa 50k”

---

## 6.8 Voice Input (optional)

* parse tiếng Việt tự nhiên

---

# ⏱️ 7. SMART TIME INPUT

* Quick select:

  * Hôm nay
  * Sáng nay
  * Tối nay
  * Hôm qua

* auto detect:

  * nếu user không chọn

---

# 🧠 8. LEARNING SYSTEM (OFFLINE)

Xây dựng rule-based learning:

* lưu:

  * lịch sử transaction
  * tần suất theo:

    * giờ
    * ngày
    * category

---

## 8.1 Confidence Score

* tính điểm:

  * theo thời gian
  * theo tần suất
* item cao nhất → highlight

---

## 8.2 Smart Correction

* nếu user sửa:

  * update lại pattern

---

# 📊 9. INSIGHT & ANALYTICS

* thống kê:

  * theo category
  * theo tháng

---

## 9.1 So sánh

* tháng này vs tháng trước

---

## 9.2 Insight

* “Bạn tiêu nhiều vào cuối tuần”
* “Ăn uống chiếm 40%”

---

## 9.3 Cảnh báo

* vượt budget
* tiêu quá nhanh

---

## 9.4 Forecast (basic offline)

* dự đoán:

  * cuối tháng còn bao nhiêu

---

# 🏦 10. SAVING SYSTEM

* nhiều mục tiêu:

  * du lịch
  * mua xe

---

## 10.1 Progress

* 20tr / 100tr

---

## 10.2 Carry over

* tiền dư tháng → saving

---

# 🎮 11. GAMIFICATION

* level tài chính
* streak:

  * không vượt budget
* badge:

  * tiết kiệm 3 tháng

---

# 🤖 12. AUTOMATION

* auto phân bổ:

  * lương → chia vào budget
* auto tạo:

  * chi tiêu cố định

---

# 🎨 13. UX REQUIREMENTS

* nhập giao dịch ≤ 2 tap
* animation:

  * rung nhẹ
  * tick ✔
* có undo

---

# 🧩 14. CUBIT STRUCTURE

Tách:

* HomeCubit
* TransactionCubit
* BudgetCubit
* SavingCubit
* SuggestionCubit (quan trọng)

---

# 📁 15. FEATURE STRUCTURE

features/

* home/
* transaction/
* budget/
* saving/
* suggestion/

---

# 🎯 16. YÊU CẦU OUTPUT

Hãy:

1. Thiết kế database schema
2. Viết model Dart
3. Viết Cubit + State
4. Flow UI từng màn
5. Logic Suggestion Engine (rule-based)

---

# ❗ LƯU Ý

* App hoạt động hoàn toàn OFFLINE
* Tối ưu performance
* UX phải nhanh và mượt
