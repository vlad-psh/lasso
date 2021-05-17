class DefinitionNode
  attr_accessor :items, :tag

  def initialize(items, tag)
    @name = tag
    @items = []

    idx = 0
    while idx < items.length
      i = items[idx]

      if i.is_a?(String)
        if i == "\uE102" # begin_subscript
          idx = sub_node(items, "\uE103", idx, :subscript)
        elsif i == "\uE100" # begin_decoration
          idx = sub_node(items, "\uE101", idx, :decoration)
        else
          i = case items[idx]
          when "\uE002" then '　'
          when "\uE003" then '🔣'
          else items[idx]
          end

          if @items.last.is_a?(String)
            @items[@items.length - 1] += i
          else
            @items << i
          end
        end
      else
        @items << {
          t: i[:text],
          q: i[:base] + (i[:base] != i[:base_reading] ? '+' + i[:base_reading] : '')
        }
      end

      idx += 1
    end
  end

  def find_from(items, search_char, idx = 0)
    while idx < items.length do
      return idx if items[idx] == search_char
      idx += 1
    end
    return nil
  end

  def sub_node(items, search_char, start_idx, tag_name)
    end_idx = find_from(items, search_char, start_idx)
    sub_items = items[(start_idx + 1)..(end_idx ? end_idx - 1 : nil)]
    @items << DefinitionNode.new(sub_items, tag_name)

    return end_idx || items.length
  end
end