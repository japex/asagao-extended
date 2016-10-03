問題03 「その他」用のテキスト入力欄を持つ選択式入力欄 の解答です。
実際のコミットは、ブランチ problem03 にあります。

モデルは Occupations, OccupationDetails の２つを追加しました。
前者に「会社員」などの職業を保持させ、後者に「その他」の具体的な説明を
保持させます。
データベースに極力 NULL を持ち込まない、という理想を追求してみました。
マイグレーション・スクリプトは下記のとおりです。
```ruby
class CreateOccupations < ActiveRecord::Migration

  def change
    create_table :occupations do |t|
      t.string  :category         , null: false
      t.boolean :needs_description, null: false, default: false
      t.integer :display_order    , null: false

      t.timestamps null: false
    end
  end
end
```
```ruby
class AddOccupationIdToMembers < ActiveRecord::Migration

  def change
    add_column :members, :occupation_id, :integer
  end
end
```
```ruby
class CreateOccupationDetails < ActiveRecord::Migration

  def change
    create_table :occupation_details do |t|
      t.references :member
      t.string     :description

      t.timestamps null: false
    end
  end
end
```

Occupation に初期データを投入するために、下記の db/seeds/development/occupations.rb を
新規作成しています。
```ruby
+CATEGORIES = %w(会社員・会社役員 自営業・自由業 公務員 学生 無職 その他)
+
+INITIAL_DISPLAY_ORDER      =    100
+INCREMENT_OF_DISPLAY_ORDER =    100
+VERY_LAST_DISPLAY_ORDER    = 999999
+
+display_order = INITIAL_DISPLAY_ORDER
+CATEGORIES.each do |category|
+  needs_description = false
+  if category == 'その他'
+    needs_description = true
+    display_order = VERY_LAST_DISPLAY_ORDER
+  end
+  Occupation.create(
+    category:          category,
+    needs_description: needs_description,
+    display_order:     display_order,
+  )
+  display_order += INCREMENT_OF_DISPLAY_ORDER
+end
```

HTMLフォームのERBテンプレートは下記のとおりです。
```erb
+  <tr>
+    <th><%= Member.human_attribute_name(:occupation) %></th>
+    <td>
+      <% @occupations.each do |occupation| -%>
+        <%= form.radio_button :occupation_id, occupation.id %>
+        <%= form.label :occupation_id, occupation.category, value: occupation.id %>
+        <br>
+        <% if occupation.needs_description -%>
+          <div id="occupation_description_<%= occupation.id %>"
+               class="occupation_description"
+               <%= @member.occupation_id != occupation.id ? :hidden : nil %>
+               >
+            <%= form.label :specifically %>
+            <%= form.fields_for :occupation_detail do |odf| %>
+              <%= odf.text_field :description %>
+            <% end -%>
+          </div>
+        <% end -%>
+      <% end -%>
+    </td>
+  </tr>
```

既存のモデル Member には下記の追加をしています。
バリデーションの前に職業をチェックし、具体的記述が必要なものであれば、
OccupationDetail の description のバリデーションをしないように設定します。
また、不要となった OccupationDetail は Admin::MembersController#update() の
save 成功時にモデルの当該メソッドを呼び出して削除しています。
```ruby
 class Member < ActiveRecord::Base
   ...

+  before_validation :skip_validation_of_occupation_description_if_not_needed
+
+  belongs_to :occupation
+  has_one :occupation_detail, dependent: :destroy
+  accepts_nested_attributes_for :occupation_detail
   ...
+  def destroy_unnecessary_occupation_detail
+    occupation_detail.try(:destroy) unless occupation.needs_description
+  end
+
   private
   ...
+  def skip_validation_of_occupation_description_if_not_needed
+    if occupation && !occupation.needs_description
+      occupation_detail.skips_validations_for_description = true
+    end
+    true
+  end
+
   ...
 end
```

新規作成したモデル OccupationDetail は下記のとおりです。
```ruby
+class OccupationDetail < ActiveRecord::Base
+  attr_accessor :skips_validations_for_description
+
+  validates :description, presence: true, length: {maximum: 10},
+              unless: -> { skips_validations_for_description }
+end
```

Admin::MembersController には下記の追加・変更をしています。
```ruby
 class Admin::MembersController < Admin::Base
+  before_action :set_occupations, only: [:new, :edit, :create, :update]
+
   ...
   def new
     @member = Member.new(birthday: Date.new(1980, 1, 1))
+    @member.build_occupation_detail unless @member.occupation_detail
     @member.build_image
   end
   ...
   def edit
     @member = Member.find(params[:id])
+    @member.build_occupation_detail unless @member.occupation_detail
     @member.build_image unless @member.image
   end
   ...
   def update
     @member = Member.find(params[:id])
     @member.assign_attributes(member_params)
     if @member.save
+      @member.destroy_unnecessary_occupation_detail
       redirect_to [:admin, @member], notice: "会員情報を更新しました。"
     else
       render "edit"
     end
   end
   ...

   private
   def member_params
-    attrs = [:number, :name, :full_name, :gender, :birthday, :email,
+    attrs = [:number, :name, :full_name, :gender, :occupation_id, :birthday, :email,
       :password, :password_confirmation, :administrator]
+    attrs << { occupation_detail_attributes: :description }
     attrs << { image_attributes: [:_destroy, :id, :uploaded_image] }
     params.require(:member).permit(attrs)
   end
   ...
+
+  def set_occupations
+    @occupations = Occupation.in_display_order
+  end
 end
```

Javascript は下記のとおりです。
```coffeescript
+$(document).on "ready page:load", ->
+  $('input[name="member[occupation_id]"]:radio').on "change", ->
+    $(".occupation_description").hide()
+    $("#occupation_description_" + $(this).val()).show()
```

以上、解答でした。



README
======

このリポジトリでは Rails アプリケーション asagao の機能拡張を試みます。

asagao は『改訂三版基礎Ruby on Rails』（2015年、インプレス刊）で使用されているサンプルアプリケーションです。

本書の読者向けの演習課題とお考えください。

機能拡張の仕様
--------------

### フォロー機能

* ブログ機能にフォロー機能を追加します。
* asagao にログインしている会員は以下のことができるようになります。
    * ブログ記事の下に表示される「フォローする」リンクをクリックすることで他の会員をフォローできます。
    * 「会員ブログ」ページの見出しの下に「フォローしている会員の記事」というリンクを追加します。
    * このリンクをクリックして、該当する記事の一覧を表示できます（新しい記事から古い記事へとソートされるものとします）。
    * フォローしている会員の記事の下に表示される「フォローをやめる」リンクをクリックすることでその会員のフォローを停止できます。
* 会員名簿（会員一覧）のページでは、フォローしている会員の名前の右側に（フォロー中）と表示されます。

### 自動更新機能

* フォローしている会員がブログ記事を投稿したときに、自動的に（ブラウザの再読込を行わずに）その記事が画面に現れるようにします。
* 具体的には、一定間隔で Ajax によって新規投稿を取得してブログ記事一覧の一番上に挿入します。
* この機能の動作確認を行う際には、二種類のブラウザ（例えば、Chrome と Firefox）を開いて、別々の会員としてログインし、一方が他方をフォローする状態にした上で、フォローされている会員がブログ記事を投稿してください。
