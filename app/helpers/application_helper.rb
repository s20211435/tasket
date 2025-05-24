module ApplicationHelper
  # パス文字列からURLを解決するヘルパーメソッド
  def resolve_path(path_string)
    if path_string.start_with?('/')
      path_string  # 既に実際のパス
    else
      begin
        send(path_string)  # ヘルパーメソッド名
      rescue NoMethodError
        '/'  # エラー時はホームにリダイレクト
      end
    end
  end
end
