db/migrate/20160923020052_create_occupations.rb
```ruby
class CreateOccupations < ActiveRecord::Migration

  def change
    create_table :occupations do |t|
      t.string  :category         , null: false
      t.boolean :needs_description, null: false, default: false

      t.timestamps null: false
    end
  end
end
```
db/migrate/20160927014503_create_occupation_details.rb
```ruby
class AddOccupationIdToMembers < ActiveRecord::Migration

  def change
    add_column :members, :occupation_id, :integer
  end
end
```
db/migrate/20160923062303_add_occupation_id_to_members.rb
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
