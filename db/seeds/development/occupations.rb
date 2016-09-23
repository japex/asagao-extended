CATEGORIES = %w(会社員・会社役員 自営業・自由業 公務員 学生 無職 その他)

CATEGORIES.each do |category|
  Occupation.create(category: category)
end
