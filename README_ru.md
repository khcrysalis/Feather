<div align="center">
    <img width="100" height="100" src="Images/512@2x.png" style="margin-right: -15px;">
</div>
<h1>Feather</h1>
<p>
    Feather - это бесплатный менеджер/установщик iOS-приложений на устройство, созданный на основе качественного UIKit.
</p>

#### README на других языках
- [English🇬🇧](https://github.com/khcrysalis/Feather/blob/main/README.md)
- [Русский🇷🇺](https://github.com/khcrysalis/Feather/blob/main/README_ru.md)

## Функции

- **Поддержка Altstore репозиториев**. *Поддержка структур репозиториев Legacy и 2.0*
- **Импорт своего собственного `.ipa` файла**.
- **Внедрение твиков при подписи приложений**.
- **Устанавливайте приложения прямо на ваше устройство по воздуху**.
- **Позволяет импортировать несколько сертификатов для удобства переключения**.
- **Настраиваемые параметры подписи**. *(имя, bundleid, версия, другие варианты настроек plist)*
- **Предназначен для использования с учетными записями Apple, которые участвуют в программе `ADP` (Apple Developer Program)**. *хотя другие сертификаты тоже подойдут!*
- **Легкая перепись**! *Если у вас есть другой сертификат, который вы хотите использовать в каком-либо приложении, вы можете переподписать и переустановить это приложение!*
- **Никакого отслеживания, аналитики или чего-то подобного**. *Ваша информация, такая как UDID и сертификаты, никогда не покинет устройство.*

> [!IMPORTANT]
> **Поддержка твиков находится в стадии бета-версии**, убедитесь, что ваши твики работают на платформе [Ellekit](https://theapplewiki.com/wiki/ElleKit) и собраны с помощью последней версии theos.
> 
> **Некоторые твики, но не все, должны работать с Feather.** Однако не ждите, что твики будут работать из коробки. Так как мы не будем менять ни одну команду загрузки dylib, которая не является CydiaSubstrate.

## Ссылки
 → [Посетите вики о Feather здесь!](https://github.com/khcrysalis/Feather/wiki)\
 → [Посетите план развития здесь!](https://github.com/khcrysalis/Feather/issues/26)

## Скриншоты

| <p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="Images/Repos.png"><source media="(prefers-color-scheme: light)" srcset="Images/Repos_L.png"><img alt="Pointercrate-pocket." src="Images/Repos_L.png" width="200"></picture></p> | <p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="Images/Store.png"><source media="(prefers-color-scheme: light)" srcset="Images/Store_L.png"><img alt="Pointercrate-pocket." src="Images/Store_L.png" width="200"></picture></p> | <p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="Images/Library.png"><source media="(prefers-color-scheme: light)" srcset="Images/Library_L.png"><img alt="Pointercrate-pocket." src="Images/Library_L.png" width="200"></picture></p> | <p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="Images/Sign.png"><source media="(prefers-color-scheme: light)" srcset="Images/Sign_L.png"><img alt="Pointercrate-pocket." src="Images/Sign_L.png" width="200"></picture></p> |
|:--:|:--:|:--:|:--:|
| **Источники** | **Магазин** | **Библиотека** | **Подпись** |
> [!Tip]
> Выберите светлый режим, чтобы увидеть скриншоты в светлом режиме!

## Как это работает

Feather позволяет импортировать пару `.p12` и `.mobileprovision` для подписи приложения (вам понадобится правильный пароль к p12 перед импортом). [Zsign](https://github.com/zhlynn/zsign) используется для подписи приложения, Feather передает ему сертификаты, которые вы выбрали на вкладке сертификатов, и подписывает приложение на вашем устройстве - после завершения подписи оно будет добавлено на вкладку подписанных приложений. После выбора приложения оно некоторое время будет сжиматься и предложит вам установить его.

## ЧаВо

> Что использует Feather для своего сервера?

Он использует сертификат [localhost.direct](https://github.com/Upinel/localhost.direct) и [Vapor](https://github.com/vapor/vapor) для самостоятельного размещения HTTPS-сервера на вашем устройстве - все, что нужно службам itms, это действительный сертификат и действительный HTTPS-сервер. Это позволяет iOS принять запрос и установить приложение.

> Включает ли Feather свой сертификат для сервера?

Да, чтобы иметь возможность устанавливать приложения на устройство, сервер должен быть HTTPS. Для этого мы используем сертификат localhost.direct при включении сервера и попытке установки.

У нас есть возможность загрузить новый сертификат, чтобы этот сервер мог работать в далеком будущем, но никаких гарантий. Это полностью зависит от владельцев localhost.direct, которые могут предоставить сертификат для использования. Если срок действия сертификата истечет, и появится новый, мы, надеюсь, сможем обновить файлы в фоновом режиме, чтобы Feather смог их получить.

> Почему Feather добавляет случайную строку к идентификатору пакета?

Новые программы ADP (Apple Developer Program), созданные после 6 июня 2021 года, требуют, чтобы приложения для разработки и специальные приложения с подписью для iOS, iPadOS и tvOS проверялись службой PPQ (Provisioning Profile Query Check) при первом запуске приложения. Для проверки устройство должно быть подключено к интернету.

PPQCheck проверяет наличие похожего идентификатора пакета в App Store, и если этот идентификатор совпадает с запускаемым приложением и оказывается подписанным сертификатом, не принадлежащим магазину, ваш Apple ID может быть отмечен и даже запрещен к использованию программы в течение длительного времени.

Именно поэтому мы добавляем случайную строку перед каждым идентификатором, это сделано в качестве меры безопасности - однако вы можете отключить ее, если вы *действительно* хотите этого, на странице настроек Feather.

> [!WARNING]
> Если вы хотите сохранить данные приложения при переустановке, убедитесь, что у вас один и тот же bundleid.

> Что такое удалить dylib внутри опций?

Есть очень конкретная причина, по которой он там находится, для тех, кто хочет удалить уже существующие инжектированные dylibs внутри, но он действительно не служит никакой другой практической пользе, кроме этого. Не используйте его, если вы не знаете, что делаете.

> А как насчет бесплатных аккаунтов разработчиков?

К сожалению, Feather вряд ли когда-либо будет поддерживать их, ведь существует множество альтернатив! Вот несколько из них: [Altstore](https://altstore.io), [Sideloadly](https://sideloadly.io/)

## Создание

```sh
git clone https://github.com/khcrysalis/feather # Клонирование
cd feather
make package SCHEME="'feather (Release)'" # Билд
```
> [!Tip]
> Используйте `SCHEME="'feather (Debug)'"` для билда с debug

## Спонсоры

| Спасибо всем моим [спонсорам](https://github.com/sponsors/khcrysalis)!! |
|:-:|
| <img src="https://raw.githubusercontent.com/khcrysalis/github-sponsor-graph/main/graph.png"> |
| _**"samara is cute" - Vendicated**_ |

## История звезд

<a href="https://star-history.com/#khcrysalis/feather&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=khcrysalis/feather&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=khcrysalis/feather&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=khcrysalis/feather&type=Date" />
 </picture>
</a>

## Благодарности

- [localhost.direct](https://github.com/Upinel/localhost.direct) - localhost с публичным сертификатом SSL с подписью CA
- [Vapor](https://github.com/vapor/vapor) - Серверный HTTP-веб-фреймворк Swift.
- [Zsign](https://github.com/zhlynn/zsign) - Позволяет подписывать приложения на устройстве, переделан для работы на других платформах, таких как iOS.
- [Nuke](https://github.com/kean/Nuke) - Кэширование изображений.
- [Asspp](https://github.com/Lakr233/Asspp) - Код для настройки http-сервера.
- [plistserver](https://github.com/QuickSign-Team/plistserver) - Размещено на https://api.palera.in


## Вклады

Они приветсвуются! :)