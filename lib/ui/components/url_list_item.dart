import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopping_lister/controllers/controllers.dart';
import 'package:shopping_lister/helpers/html_util.dart';
import 'package:sizer/sizer.dart';

import '../../models/url_model.dart';

class UrlListItem extends StatefulWidget {
  final UrlModel urlModel;
  final Function(UrlModel) onEdit;
  final VoidCallback onDelete;
  final int index;

  const UrlListItem({
    required this.urlModel,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  _UrlListItemState createState() => _UrlListItemState();
}

class _UrlListItemState extends State<UrlListItem> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onEdit(widget.urlModel);
      },
      child: Container(
        width: 94.w,
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
                  GestureDetector(
                    onTap: () {
                      setState(() {
                          widget.urlModel.rotateImageUrls();
                          final StorageController sController = Get.put(StorageController());
                          sController.updateData(widget.urlModel);
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 33.w,
                          maxHeight: 33.h,
                        ),
                        child: HtmlUtil.isValidURL(widget.urlModel.imageUrl0)
                            ? Image.network(
                          widget.urlModel.imageUrl0,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print('🟥Url Image load failed: $error' + widget.urlModel.imageUrl0);
                            if (widget.urlModel.imageUrl0.isEmpty)//TODO fix
                              return Image.asset('assets/images/ic_blank.png');
                            else
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
                            widget.urlModel.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.urlModel.note,
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
                    widget.onDelete();
                  },
                  child: Icon(
                    Icons.delete,
                    color: Colors.black87,
                    size: 25.sp,
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
