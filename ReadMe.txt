// In ViewController

var customSearchBar: CustomSearchBar!

customSearchBar = CustomSearchBar(frame: frame, font: font, textColor: textColor, placeholder: LocStr(SEARCH_BAR_PLACEHOLDER), placeholderColor: APP_THEME_COLOR)
customSearchBar.backgroundImage = UIImage(named: INje_search_textbox)
        customSearchBar.showsBookmarkButton = true
        customSearchBar.showsCancelButton = true
        customSearchBar.delegate = self
customSearchBar.clipsToBounds = true
        // 圖片顯得有點小
        customSearchBar.setImage(UIImage(named: INsearch_search), for: .search, state: .normal)
        customSearchBar.showsBookmarkButton = false
        customSearchBar.showsCancelButton = false