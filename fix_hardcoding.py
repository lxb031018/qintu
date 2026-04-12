# 批量修复硬编码脚本

import re
import os

# 定义替换规则
replacements = {
    # 颜色替换
    'Colors.white': 'AppColors.cardBackground',
    'Colors.red': 'AppColors.errorColor',
    'Colors.green': 'AppColors.successColor',
    'Colors.orange': 'AppColors.warningColor',
    'Colors.blue': 'AppColors.infoColor',
    'Colors.grey': 'AppColors.disabledColor',
    'Colors.black87': 'AppColors.black87',
    
    # 灰色 shades - 这些需要更精确的匹配
    'Colors.grey.shade400': 'AppColors.grey400',
    'Colors.grey.shade500': 'AppColors.grey500',
    'Colors.grey.shade600': 'AppColors.grey600',
    'Colors.grey.shade700': 'AppColors.grey700',
    'Colors.grey.shade100': 'AppColors.grey100',
    'Colors.grey.shade300': 'AppColors.grey300',
    
    # 蓝色 shades
    'Colors.blue.shade50': 'AppColors.blue50',
    'Colors.blue.shade700': 'AppColors.blue700',
    'Colors.blue.shade200': 'AppColors.blue200',
    'Colors.blue.shade900': 'AppColors.blue900',
    'Colors.blue.shade100': 'AppColors.blue200',
    
    # 绿色 shades
    'Colors.green.shade100': 'AppColors.green100',
    
    # 橙色 shades
    'Colors.orange.shade100': 'AppColors.orange100',
    
    # Duration 替换
    'Duration(seconds: 30)': 'AppDurations.networkTimeout',
    'Duration(seconds: 2)': 'AppDurations.snackbarShort',
    'Duration(seconds: 1)': 'AppDurations.splashMinDuration',
    'Duration(milliseconds: 200)': 'AppDurations.fastAnimation',
    'Duration(milliseconds: 300)': 'AppDurations.standardAnimation',
}

# 需要添加 import 的文件
files_to_process = []

# 遍历 lib 目录
lib_dir = r'D:\AllCodes\qintu\lib'
for root, dirs, files in os.walk(lib_dir):
    # 跳过 constants 目录
    if 'constants' in root:
        continue
    # 跳过生成的文件
    if any(f.endswith('.freezed.dart') or f.endswith('.g.dart') for f in files):
        continue
    for file in files:
        if file.endswith('.dart'):
            files_to_process.append(os.path.join(root, file))

print(f'找到 {len(files_to_process)} 个 Dart 文件')

# 统计
total_replacements = 0
files_modified = 0

for file_path in files_to_process:
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        file_replacements = 0
        
        # 应用替换
        for old, new in replacements.items():
            count = content.count(old)
            if count > 0:
                content = content.replace(old, new)
                file_replacements += count
        
        # 如果有修改，添加必要的 import
        if content != original_content:
            # 检查是否需要添加 import
            needs_app_colors = any(color in content for color in ['AppColors.'])
            needs_app_durations = any(duration in content for duration in ['AppDurations.'])
            
            if needs_app_colors and "import 'package:qintu/constants/app_colors.dart'" not in content:
                # 在最后一个 import 后添加
                import_pattern = r"(import '[^']+\dart';\n)"
                matches = list(re.finditer(import_pattern, content))
                if matches:
                    last_import = matches[-1]
                    content = content[:last_import.end()] + "import 'package:qintu/constants/app_colors.dart';\n" + content[last_import.end():]
            
            if needs_app_durations and "import 'package:qintu/constants/app_durations.dart'" not in content:
                import_pattern = r"(import '[^']+\dart';\n)"
                matches = list(re.finditer(import_pattern, content))
                if matches:
                    last_import = matches[-1]
                    content = content[:last_import.end()] + "import 'package:qintu/constants/app_durations.dart';\n" + content[last_import.end():]
            
            # 写回文件
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            
            total_replacements += file_replacements
            files_modified += 1
            print(f'✓ {file_path}: {file_replacements} 处修改')
    
    except Exception as e:
        print(f'✗ {file_path}: 错误 - {e}')

print(f'\n完成！')
print(f'修改了 {files_modified} 个文件')
print(f'总共 {total_replacements} 处替换')
