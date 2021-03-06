//
//  TableViewSectionFooterDataSource.swift
//  DataSource-Swift
//
//  Created by jqy on 2020/11/24.
//

import UIKit

/*
  只有尾部列表类型
 */

class TableViewSectionFooterDataSource<RowModelClass,SectionModelClass>: NSObject,UITableViewDataSource,UITableViewDelegate {
    
    private var configureCell   : ConfigureCellCallback<RowModelClass>
    private var configureFooter : ConfigureTableViewHeaderFooterCallback<SectionModelClass>
    private var modelStyle      : TableViewDataSourceModelStyle<RowModelClass,SectionModelClass>
    private var dataArray       : [SectionModelClass]?
    private var heightForRow    : HeightForRowCallback<RowModelClass>?
    private var heightForFooter : HeightForTableViewHeaderFooterCallback<SectionModelClass>?
    private var didSelectRow    : DidSelectRowCallback<RowModelClass>?
    
    init(modelStyle      : TableViewDataSourceModelStyle<RowModelClass,SectionModelClass>,
         configureCell   : @escaping ConfigureCellCallback<RowModelClass>,
         configureFooter : @escaping ConfigureTableViewHeaderFooterCallback<SectionModelClass>) {
         self.configureCell   = configureCell
         self.configureFooter = configureFooter
         self.modelStyle      = modelStyle
         switch modelStyle {
            case .grouped1(let data):
                self.dataArray = data as? [SectionModelClass]
            case .grouped2(let data, _, _):
                self.dataArray = data
         }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        self.dataArray?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch modelStyle {
        case .grouped1(_):
            return (self.dataArray as? [[RowModelClass]])?[section].count ?? 0
        case .grouped2(_,let numberOfRows,_):
            return numberOfRows(tableView,self.modelOfSectionIn(section),section) ?? 0
        }
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.configureCell(tableView,self.modelOfRowIn(tableView,indexPath),indexPath)
    }
       
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        self.configureFooter(tableView,self.modelOfSectionIn(section),section)
    }
       
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.didSelectRow?(tableView,self.modelOfRowIn(tableView,indexPath),indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        heightForRow?(tableView,self.modelOfRowIn(tableView,indexPath),indexPath) ?? tableView.rowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        heightForFooter?(tableView,self.modelOfSectionIn(section), section) ?? tableView.sectionFooterHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0.1
    }
    
    private func modelOfRowIn(_ tableView:UITableView,_ indexPath:IndexPath) -> RowModelClass? {
        switch modelStyle {
        case .grouped1(_):
            return (self.dataArray as? [[RowModelClass]])?[indexPath.section][indexPath.row]
        case .grouped2(_,_,let modelForRow):
            return modelForRow(tableView,self.modelOfSectionIn(indexPath.section),indexPath)
        }
    }
    
    func configureRowHeight(_ callback:@escaping HeightForRowCallback<RowModelClass>) {
        self.heightForRow = callback
    }
    
    func configureFooterHeight(_ callback:@escaping HeightForTableViewHeaderFooterCallback<SectionModelClass>) {
        self.heightForFooter = callback
    }
    
    func didSelectRow(_ callback:@escaping DidSelectRowCallback<RowModelClass>) {
        self.didSelectRow = callback
    }
    
    private func modelOfSectionIn(_ section: Int) -> SectionModelClass? {
        self.dataArray?[section]
    }
    
    func addData(_ dataArray:[SectionModelClass]) {
         self.dataArray = dataArray
    }
}
