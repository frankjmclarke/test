import 'package:flutter/material.dart';
import '../../helpers/html_util.dart';
import '../../models/category_model.dart';
import 'package:sizer/sizer.dart';

class CatListItem extends StatelessWidget {
  final CategoryModel catModel;
  final Function(CategoryModel) onEdit;
  final VoidCallback onDelete;
  final int index;

  const CatListItem({
    required this.catModel,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onEdit(catModel);
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.94,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
          ),
          color: Colors.white70,
          elevation: 10,
          child: Stack(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 33.w,
                        maxHeight: 33.h,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: HtmlUtil.isValidURL(catModel.imageUrl)
                            ? Image.network(
                          catModel.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print('🟥Url Image load failed: $error' + catModel.imageUrl);
                            return Image.asset('assets/images/ic_launcher.png');
                          },
                        )
                            : Image.asset('assets/images/ic_launcher.png'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(2, 2, 0, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            catModel.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            catModel.numItems.toString(),
                            style: TextStyle(
                              fontSize: 12.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 5.0,
                right: 5.0,
                child: GestureDetector(
                  onTap: () {
                    onDelete();
                  },
                  child: Icon(
                    Icons.delete,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
