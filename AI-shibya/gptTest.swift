//
//  gptTest.swift
//  AI-shibya
//
//  Created by 疋田朋也 on 2024/10/10.
//

import UIKit

class gptTestViewController: UIViewController {

    let responseLabel = UILabel()
    let titleLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    @objc func StartButtonTapped(){
        Task {
            await fetchOpenAIResponse()
            responseLabel.text = "Loading..."
        }
    }

    func setupUI() {
        view.backgroundColor = .white

        responseLabel.numberOfLines = 0
        responseLabel.textAlignment = .center
        responseLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(responseLabel)
        
        titleLabel.text = "APIdemo!"
        titleLabel.font = UIFont.systemFont(ofSize: 32)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let button = UIButton(type: .system)
        button.setTitle("Test", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self,action: #selector(StartButtonTapped),for: .touchUpInside)


        view.addSubview(titleLabel)
        view.addSubview(button)

        // ラベルのレイアウト
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            responseLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            responseLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            responseLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            button.topAnchor.constraint(equalTo: responseLabel.bottomAnchor, constant: 20),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    // OpenAI APIへのリクエストを非同期で行う関数
    func fetchOpenAIResponse() async {
        // OpenAI APIのエンドポイントとAPIキー
        let apiKey = "GPT_API_KEY"
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!

        // リクエストのボディ部分
        let messages = [
            ["role": "user",
             "system": "",
             "content": "こんにちは！渋谷の観光スポットを有名な場所以外で3つほど出力して欲しいです。"]
        ]

        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messages
        ]

        // URLリクエストの作成
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // リクエストのボディをJSONにエンコード
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            DispatchQueue.main.async {
                self.responseLabel.text = "エラー: \(error.localizedDescription)"
            }
            return
        }

        // 非同期でリクエストを実行
        do {
            let (data, _) = try await URLSession.shared.data(for: request)

            // JSONレスポンスをパース
            if let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = jsonResponse["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any],
               let content = message["content"] as? String {
                DispatchQueue.main.async {
                    self.responseLabel.text = content
                }
            } else {
                DispatchQueue.main.async {
                    self.responseLabel.text = "不正なレスポンス"
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.responseLabel.text = "エラー: \(error.localizedDescription)"
            }
        }
    }
}

#Preview(){
    ViewController()
}
