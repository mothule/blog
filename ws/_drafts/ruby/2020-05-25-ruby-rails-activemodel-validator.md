---
title: RailsのValidatorのヘルパー一覧と自作やifとか
categories: ruby rails
tags: ruby rails active-model
---

ActiveModel::Validatorの自作、予め用意されてるヘルパー一覧、if/unlessオプションの使い方

`validates :name, options...`

- presence
- uniqueness
  - DEPRECATION WARNING: Uniqueness validator will no longer enforce case sensitive comparison in Rails 6.1. To continue case sensitive comparison on the :name attribute in PlayLocation model, pass `case_sensitive: true` option explicitly to the uniqueness validator. (called from irb_binding at (irb):4)
    - uniqueness: true # when not string
    - uniqueness: { case_sensitive: true } # when string
- length
- numericality
- format
- if
- unless
- on 実行タイミング
- validate
- ActiveModel::Validator
  - validates_with
- ActiveModel::
