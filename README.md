# DNSBL Checker

DNSBL Checker is a shell script that checks a list of IP addresses against multiple DNS-based blackhole lists (DNSBLs) and generates customizable reports. It also supports email and Telegram alerts for blacklisted IPs.

---

## 🔧 Features

- Check multiple IP addresses against DNSBL providers
- JSON, HTML, or plain text report formats
- Email and Telegram notifications for blacklisted IPs
- Clean and modular Bash code
- Lightweight and easy to deploy on any Linux server

---

## 📦 Requirements

- `dig` (from `dnsutils` package)
- `mail` (for email notifications)
- `curl` (for Telegram API)
- Bash 4+

---

## 📂 Setup

1. **Clone the repository**

   ```bash
   git clone https://github.com/MrAriaNet/dnsbl-checker.git
   cd dnsbl-checker
   ```

2. **Configure settings**
   Edit the `dnsbl.config` file:

   ```bash
   nano dnsbl.config
   ```

3. **Run the script**

   ```bash
   bash dnsbl-checker.sh
   ```

   You'll be asked to choose the output format: `text`, `json`, or `html`.

---

## 📄 Configuration Options (`dnsbl.config`)

| Variable         | Description                                   |
| ---------------- | --------------------------------------------- |
| `ipAddresses`    | List of IPs to check                          |
| `dnsblList`      | List of DNSBL zones                           |
| `logFolder`      | Folder to store logs and reports              |
| `logFiles`       | Filename for blacklist log                    |
| `emailEnable`    | Set to `YES` to enable email alerts           |
| `emailTo`        | List of email addresses to notify             |
| `emailFrom`      | Sender address for email alerts               |
| `SMTPServerIP`   | SMTP server address                           |
| `mailUserName`   | SMTP username                                 |
| `mailPassword`   | SMTP password                                 |
| `telegramEnable` | Set to `YES` to enable Telegram notifications |
| `telegramToken`  | Bot token from @BotFather                     |
| `chatIDs`        | List of Telegram chat IDs to notify           |

---

## 📤 Output

Depending on your selected format, the report will be saved to:

* `logs/report.txt` (Text)
* `logs/report.json` (JSON)
* `logs/report.html` (HTML)

---

## 📬 Example Alerts

### Email:

> Subject: Blacklist Alert
> Your server IP 1.2.3.4 is listed in DNSBL: zen.spamhaus.org

### Telegram:

```
Your server IP 1.2.3.4 is listed in DNSBL: zen.spamhaus.org
```

---

## 🛡 License

This project is licensed under the [MIT License](LICENSE).

---

## 👤 Author

Made with ❤️ by **Aria Jahangiri Far**
[GitHub Profile](https://github.com/MrAriaNet)

---

## 🌐 Contributions

Pull requests are welcome. Please open an issue first to discuss major changes.
