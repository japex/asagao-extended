CATEGORIES = %w(会社員・会社役員 自営業・自由業 公務員 学生 無職 その他)

INITIAL_DISPLAY_ORDER      =    100
INCREMENT_OF_DISPLAY_ORDER =    100
VERY_LAST_DISPLAY_ORDER    = 999999

display_order = INITIAL_DISPLAY_ORDER
CATEGORIES.each do |category|
  needs_description = false
  if category == 'その他'
    needs_description = true
    display_order = VERY_LAST_DISPLAY_ORDER
  end
  Occupation.create(
    category:          category,
    needs_description: needs_description,
    display_order:     display_order,
  )
  display_order += INCREMENT_OF_DISPLAY_ORDER
end
