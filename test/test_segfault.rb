# encoding: ASCII-8BIT
# -*- mode: ruby; ruby-indent-level: 4; tab-width: 4; indent-tabs-mode: t -*-
#												vim:sw=4:ts=4
#
require 'helper'

module Syck
  class SegfaultTests < Test::Unit::TestCase

    # Test 1: Massive nested sequences
    def test_massive_sequence_segfault
      yaml_content = create_massive_sequence_yaml(50, 100)
      run_segfault_test(yaml_content, "Massive sequence should not cause segfault")
    end

    # Test 2: Massive map with many keys
    def test_massive_map_segfault
      yaml_content = create_massive_map_yaml(10000)
      run_segfault_test(yaml_content, "Massive map should not cause segfault")
    end

    # Test 3: Complex anchors and references
    def test_complex_anchors_segfault
      yaml_content = create_complex_anchor_yaml(100, 1000)
      run_segfault_test(yaml_content, "Complex anchors should not cause segfault")
    end

    # Test 4: Mixed complex structure
    def test_mixed_complex_structure_segfault
      yaml_content = create_mixed_complex_yaml
      run_segfault_test(yaml_content, "Mixed complex structure should not cause segfault")
    end

    # Test 5: Stress Test with Memory Pressure
    def test_stress_test_with_memory_pressure
      yaml_content = create_stress_test_yaml
      run_stress_test(yaml_content, "Stress test with memory pressure should not cause segfault")
    end

private

  # Common test logic for standard segfault tests
  def run_segfault_test(yaml_content, message, iterations = 10)
    assert_nothing_raised(message) do
      iterations.times do |i|
        result = Syck.load(yaml_content)
        aggressively_access_data_structures(result)
        GC.start if i % 3 == 0
      end
    end
  end

  # Specialized test logic for stress tests with different access patterns
  def run_stress_test(yaml_content, message, iterations = 50)
    assert_nothing_raised(message) do
      iterations.times do |iteration|
        result = Syck.load(yaml_content)

        # Specialized access pattern for stress test structure
        if result && result['stress_test'] && result['stress_test']['sequences']
          sequences = result['stress_test']['sequences']
          sequences.each_with_index do |seq_item, seq_idx|
            if seq_item.is_a?(Hash)
              seq_item.each do |seq_key, seq_value|
                if seq_value.is_a?(Array)
                  seq_value.each_with_index do |element, element_idx|
                    element.to_s if element
                  end
                end
              end
            end
          end
        end

        GC.start
      end
    end
  end

  # Common aggressive data structure access pattern
  def aggressively_access_data_structures(result)
    return unless result.is_a?(Hash)

    result.each do |key, value|
      if value.is_a?(Array)
        value.each_with_index do |item, idx|
          # Force access that might trigger bounds issues
          item.to_s if item
        end
      elsif value.is_a?(Hash)
        value.each do |k, v|
          k.to_s if k
          v.to_s if v
        end
      end
    end
  end

  # Helper method to create massive nested sequences
  def create_massive_sequence_yaml(depth, width)
    yaml = "massive_seq:\n"

    # Create deeply nested sequences
    depth.times do |d|
      indent = "  " * (d + 1)
      yaml += "#{indent}- level_#{d}:\n"

      # Add many items at each level
      width.times do |w|
        yaml += "#{indent}  - item_#{d}_#{w}\n"
      end
    end

    yaml
  end

  # Helper method to create massive map with many keys
  def create_massive_map_yaml(num_keys)
    yaml = "massive_map:\n"

    num_keys.times do |i|
      yaml += "  key_#{i}: value_#{i}\n"
    end

    yaml
  end

  # Helper method to create complex anchors and references
  def create_complex_anchor_yaml(num_anchors, num_refs)
    yaml = ""

    # Create many anchors
    num_anchors.times do |i|
      yaml += "anchor_#{i}: &anchor_#{i}\n"
      yaml += "  - data_#{i}_1\n"
      yaml += "  - data_#{i}_2\n"
      yaml += "  - data_#{i}_3\n"
    end

    # Create many references
    yaml += "references:\n"
    num_refs.times do |i|
      anchor_idx = i % num_anchors
      yaml += "  ref_#{i}: *anchor_#{anchor_idx}\n"
    end

    yaml
  end

  # Helper method to create mixed complex structure
  def create_mixed_complex_yaml
    yaml = "# Complex mixed structure with potential for bounds issues\n"
    yaml += "root: &root_anchor\n"
    yaml += "  sequences:\n"

    # Add many nested sequences
    50.times do |i|
      yaml += "    - seq_#{i}:\n"
      25.times do |j|
        yaml += "        - item_#{i}_#{j}\n"
      end
    end

    yaml += "  maps:\n"
    # Add many nested maps
    50.times do |i|
      yaml += "    map_#{i}:\n"
      25.times do |j|
        yaml += "      key_#{i}_#{j}: value_#{i}_#{j}\n"
      end
    end

    # Add many references to stress the anchor system
    yaml += "references:\n"
    100.times do |i|
      yaml += "  ref_#{i}: *root_anchor\n"
    end

    yaml
  end

  # Helper method to create stress test YAML with extreme memory pressure
  def create_stress_test_yaml
    # Create a YAML with thousands of nested elements
    yaml = "stress_test:\n"
    yaml += "  sequences:\n"

    # Create many sequences with many elements
    500.times do |i|
      yaml += "    - seq_#{i}:\n"
      200.times do |j|
        yaml += "        - element_#{i}_#{j}\n"
      end
    end

    yaml
  end

  end
end
