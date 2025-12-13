#!/usr/bin/env bash

set -o nounset
set -o pipefail

if [ "$#" -ne 1 ]; then
 echo "Использование: $0 sales.txt"
 exit 1
fi

FILE="$1"

if [[ ! -f "$FILE" ]]; then
 echo "Файл $FILE не найден"
 exit 2
fi

total=0
declare -A day_sum
declare -A product_count
declare -A product_sum

while read -r date day product price qty; do
 # пропускаем пустые строки
 if [[ -z "$date" ]]; then
 continue
 fi

 # проверка количества
 if ! [[ "$qty" =~ ^[0-9]+$ ]]; then
 echo "Предупреждение: некорректное количество '$qty' в строке: $date $day $product $price $qty"
 continue
 fi

 # цена может быть десятичной → считаем в копейках/центах
 price_cents=$(awk -v p="$price" 'BEGIN { printf("%.0f", p*100) }')
 sale=$(( price_cents * qty ))
 total=$(( total + sale ))

 # сумма за день
 day_key="$date|$day"
 day_sum["$day_key"]=$(( ${day_sum["$day_key"]:-0} + $sale ))

 # популярный товар
 product_count["$product"]=$(( ${product_count["$product"]:-0} + qty ))
 product_sum["$product"]=$(( ${product_sum["$product"]:-0} + sale ))

done < "$FILE"

# вывод общей суммы
total_display=$(awk -v c="$total" 'BEGIN { printf("%.2f", c/100) }')
echo "Общая сумма продаж: $total_display"

# день с максимальной выручкой
best_day=""
best_day_sum=0
for k in "${!day_sum[@]}"; do
 if (( day_sum["$k"] > best_day_sum )); then
 best_day_sum=${day_sum["$k"]}
 best_day=$k
 fi
done

IFS="|" read best_date best_weekday <<< "$best_day"
best_day_sum_display=$(awk -v c="$best_day_sum" 'BEGIN { printf("%.2f", c/100) }')
echo "День с наибольшей выручкой: $best_date $best_weekday (сумма продаж: $best_day_sum_display)"

# популярный товар
best_product=""
best_qty=0
best_product_sum=0
for p in "${!product_count[@]}"; do
 if (( product_count["$p"] > best_qty )); then
 best_qty=${product_count["$p"]}
 best_product=$p
 best_product_sum=${product_sum["$p"]}
 fi
done

best_product_sum_display=$(awk -v c="$best_product_sum" 'BEGIN { printf("%.2f", c/100) }')
echo "Популярный товар: $best_product (количество проданных единиц: $best_qty, сумма продаж: $best_product_sum_display)"