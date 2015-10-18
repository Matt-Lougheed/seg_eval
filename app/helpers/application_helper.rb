module ApplicationHelper
    def highlight_code(algorithm)
        file_type = get_file_type(File.extname(algorithm.filename))
        Pygments.highlight(File.read(Rails.root.join('public/uploads/algorithm',algorithm.user.id.to_s,algorithm.id.to_s,algorithm.filename)), :lexer => file_type).html_safe
    end

    def get_file_type(file_extension)
        puts file_extension
        case file_extension
        when ".rb"
            return 'ruby'
        when ".py"
            return 'python'
        when ".m"
            return 'matlab'
        when ".java"
            return 'java'
        when ".c"
            return 'c'
        when ".cpp"
            return 'c++'
        when ".cxx"
            return 'c++'
        else
            return "unknown"
        end
    end
end
