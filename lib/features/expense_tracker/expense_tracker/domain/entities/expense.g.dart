// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExpenseImpl _$$ExpenseImplFromJson(Map<String, dynamic> json) =>
    _$ExpenseImpl(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String,
      amount: json['amount'] as String,
      category: json['category'] as String,
      date: json['date'] as String,
      description: json['description'] as String? ?? '',
    );

Map<String, dynamic> _$$ExpenseImplToJson(_$ExpenseImpl instance) =>
    <String, dynamic>{
      if (instance.id case final value?) 'id': value,
      'title': instance.title,
      'amount': instance.amount,
      'category': instance.category,
      'date': instance.date,
      'description': instance.description,
    };
