import { query, body, param } from "express-validator";

import { authValidation, _idValidation } from "./validations";

export const GetValidation = [
  query("userID").optional(),
  query("_id").optional().isMongoId().withMessage("Invalid _id format"),
  query("search").optional(),
  query("limit").optional().isInt().withMessage("Limit must be an integer"),
  query("page").optional().isInt().withMessage("Page must be an integer"),
];
export const GetSingleValidation = [
  param("_id").isMongoId().withMessage("Invalid _id format"),
];

export const DeleteValidation = [_idValidation, ...authValidation];
export const PatchValidation = [
  _idValidation,
  ...authValidation,
  body("content").notEmpty().withMessage("Content needed"),
];
export const PostValidation = [
  ...authValidation,
  body("content").notEmpty().withMessage("Content is required"),
];
export const LikesValidation = [_idValidation, ...authValidation];
export const CommentValidation = [
  _idValidation,
  ...authValidation,
  body("content").notEmpty().withMessage("Content is required"),
];
