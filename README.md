# Platon модуль для NoDeny 49/50

Модуль для биллинговой системы NoDeny реализует протокол взаимодействия с [платежной системой Platon](http://www.platon.ua).

## Установка

- Скопировать скрипт result.pl в директорию /usr/local/www/apache22/cgi-bin/platon
- Установить пароль PASSWORD в с крипте result.pl
- Скопировать строку настройки из plugin_reestr.cfg в файл /usr/local/nodeny/web/plugin_reestr.cfg
- Исправить скрипт биллинга /usr/local/nodeny/web/paystype.pl аналогично вложенному,
  чтобы корректно отображались платежные категории
- Скопировать Splaton.pl в директорию /usr/local/nodeny/web
- Установить KEY и PASSWORD в скрипте Splaton.pl
- Изменить STAT_HOST в скрипте Splaton.pl на реальный хост статистики (например, stat.provider.ua)
- В административной панели биллинга добавить модуль Splaton
- В клиентской статистике должен появиться новый раздел

## Maintainers and Authors

Yuriy Kolodovskyy (https://github.com/kolodovskyy)

## License

MIT License. Copyright 2015 [Yuriy Kolodovskyy](http://twitter.com/kolodovskyy)
