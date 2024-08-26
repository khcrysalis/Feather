<div align="center">
    <img width="100" height="100" src="Images/512@2x.png" style="margin-right: -15px;">
</div>
<h1>Feather</h1>
<p>
    Feather - это бесплатный менеджер/установщик iOS-приложений на устройство, созданный на основе качественного UIKit.
</p>





## Функции
- **Поддержка Altstore репозиториев**. *Поддержка структур репозиториев Legacy и 2.0*

- **Импорт своего собственного `.ipa` файла**.
- **Внедрение твиков при подписи приложений**.
- **Устанавливайте приложения прямо на ваше устройство по воздуху**.
- **Позволяет импортировать несколько сертификатов для удобства переключения**.
- **Настраиваемые параметры подписи**. *(имя, бандл айди, версия, и другие опции plist)*
- **Предназначен для использования с учетными записями Apple, которые участвуют в программе `ADP` (Apple Developer Program)**. *однако другие сертификаты также могут работать!*
- **Легкая перепись**! *Если у вас есть другой сертификат, который вы хотите использовать в каком-либо приложении, вы можете удалить и переустановить это приложение!*
- **Никакого отслеживания, аналитики или чего-то подобного**. *Ваша информация, такая как UDID и сертификаты, никогда не покинет устройство.*

> [!IMPORTANT]
> **Поддержка твиков находится в стадии бета-версии**, убедитесь, что ваши твики работают на платформе [Ellekit](https://theapplewiki.com/wiki/ElleKit) и собраны с помощью последней версии theos.
> 
> **Некоторые твики, но не все, должны работать с Feather.** Однако не ждите, что твики будут работать из коробки. Так как мы не будем менять ни одну команду загрузки dylib, которая не является CydiaSubstrate.

## Скриншоты

| <p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="Images/Repos.png"><source media="(prefers-color-scheme: light)" srcset="Images/Repos_L.png"><img alt="Pointercrate-pocket." src="Images/Repos_L.png" width="200"></picture></p> | <p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="Images/Store.png"><source media="(prefers-color-scheme: light)" srcset="Images/Store_L.png"><img alt="Pointercrate-pocket." src="Images/Store_L.png" width="200"></picture></p> | <p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="Images/Library.png"><source media="(prefers-color-scheme: light)" srcset="Images/Library_L.png"><img alt="Pointercrate-pocket." src="Images/Library_L.png" width="200"></picture></p> | <p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="Images/Sign.png"><source media="(prefers-color-scheme: light)" srcset="Images/Sign_L.png"><img alt="Pointercrate-pocket." src="Images/Sign_L.png" width="200"></picture></p> |
|:--:|:--:|:--:|:--:|
| **Источники** | **Магазин** | **Библиотека** | **Подпись** |
> Совет: Выберите светлый режим, чтобы увидеть скриншоты в светлом режиме!

## Как это работает

Feather позволяет импортировать пару `.p12` и `.mobileprovision` для подписи приложения (вам понадобится правильный пароль к p12 перед импортом). [Zsign](https://github.com/zhlynn/zsign) используется для подписи приложения, Feather передает ему сертификаты, которые вы выбрали на вкладке сертификатов, и подписывает приложение на вашем устройстве - после завершения подписи оно будет добавлено на вкладку подписанных приложений. После выбора приложения оно некоторое время будет сжиматься и предложит вам установить его.

## ЧаВо

> Что использует Feather для своего сервера?

Он использует сертификат [localhost.direct](https://github.com/Upinel/localhost.direct) и [Vapor](https://github.com/vapor/vapor) для самостоятельного размещения HTTPS-сервера на вашем устройстве - все, что нужно службам itms, это действительный сертификат и действительный HTTPS-сервер. Это позволяет iOS принять запрос и установить приложение.

> Почему Feather добавляет случайную строку к идентификатору пакета?

Новые программы ADP (Apple Developer Program), созданные после 6 июня 2021 года, требуют, чтобы приложения для разработки и специальные приложения с подписью для iOS, iPadOS и tvOS проверялись службой PPQ (Provisioning Profile Query Check) при первом запуске приложения. Для проверки устройство должно быть подключено к интернету.

PPQCheck проверяет наличие похожего идентификатора пакета в App Store, и если этот идентификатор совпадает с запускаемым приложением и оказывается подписанным сертификатом, не принадлежащим магазину, ваш Apple ID может быть отмечен и даже запрещен к использованию программы в течение длительного времени.

Именно поэтому мы добавляем случайную строку перед каждым идентификатором, это сделано в качестве меры безопасности - однако вы можете отключить ее, если вы *действительно* хотите этого, на странице настроек Feather.

*ПРИМЕЧАНИЕ: ЕСЛИ ВЫ ХОТИТЕ СОХРАНИТЬ ДАННЫЕ ПРИЛОЖЕНИЯ ПРИ ПЕРЕУСТАНОВКЕ, УБЕДИТЕСЬ, ЧТО У ВАС ОДИН И ТОТ ЖЕ BUNDLEID.*

## Создание

```sh
git clone https://github.com/khcrysalis/feather # Клонирование
cd feather
make package SCHEME="'feather (Release)'" # Билд
```
> Используйте `SCHEME="'feather (Debug)'"` для билда с debug

## Благодарности

- [localhost.direct](https://github.com/Upinel/localhost.direct) - localhost с публичным сертификатом SSL с подписью CA
- [Vapor](https://github.com/vapor/vapor) - Серверный HTTP-веб-фреймворк Swift.
- [Zsign](https://github.com/zhlynn/zsign) - Позволяет подписывать приложения на устройстве, переделан для работы на других платформах, таких как iOS.
- [Nuke](https://github.com/kean/Nuke) - Кэширование изображений.
- [Asspp](https://github.com/Lakr233/Asspp) - Код для настройки http-сервера.

<!-- - [plistserver](https://github.com/QuickSign-Team/plistserver) - Hosted on https://api.palera.in
> NOTE: The original license to plistserver is [GPL](https://github.com/nekohaxx/plistserver/commit/b207a76a9071a695d8b498db029db5d63a954e53), so changing the license is NOT viable as technically it's irrevocable. We are allowed to host it on our own server for use in Feather by technicality.  -->

## История звезд

<a href="https://star-history.com/#khcrysalis/feather&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=khcrysalis/feather&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=khcrysalis/feather&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=khcrysalis/feather&type=Date" />
 </picture>
</a>

## Вклады

Они приветсвуются! :)

## Предыстория

Существовал инструмент под названием ESign (Easy Sign), который позволял беспрепятственно загружать приложения на устройство с интернета, однако выяснилось, что он, к сожалению, отправляет аналитику в другое место. Существовали средства, которые якобы удаляли аналитику, но трудно определить, действительно ли они устраняли проблему.

Поэтому я решила создать альтернативу с аналогичными функциями, чтобы не использовать этот инструмент вместе с другими. Было проведено много исследований, чтобы заставить его работать, и первоначально он впервые заработал несколько месяцев назад! Конечно, без помощи Dhinakg в открытии вы можете использовать локальный сервер для развертывания приложения на вашем устройстве!

И теперь мы здесь! Надеюсь, это удовлетворит большинство людей, которые хотят загружать приложения из интернета с помощью аккаунта разработчика или вообще!