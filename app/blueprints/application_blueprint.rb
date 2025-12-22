# typed: false

class ApplicationBlueprint < Blueprinter::Base
  # BluePrint view 規則
  # 1. default view、定義なし
  # 基本的にfieldの定義のみ、N+1を避けるためassociationの定義を極力しない

  # 2. normal view 汎用的なview 最低限必要なassociationはここに定義
  # ex) 一覧API用のview
  # view :normal do
  #   association :items, blueprint: ItemBlueprint
  # end

  # 3. detailed view 詳細API用のview
  # 対象のモデルの詳細APIで含めたいリレーションを定義
  # view :detailed do
  #   include_view :normal
  #   association :images, blueprint: ImagesBlueprint
  #   association :parent, blueprint: ParentBlueprint
  # end

  # 4. embedded view 親クラスからの埋め込み用view
  # 親クラスから詳細までシリアライズしたい場合、循環参照を避けるため、絞り込んだassociationを定義
  # view :detailed do
  #   include_view :normal
  #   association :images, blueprint: ImagesBlueprint
  # end
end
